---
title: How to make an ubuntu repo mirror that actually works
tags: ubuntu, linux, bash
---

DE VERSION

## Introduction

All ubuntu mirrors I've seen (such as `de.archive.ubuntu.com`) become inconsistent when they're being updated. I don't know why they'd do this in the first place, but it appears the the indexes are updated first, and then the packages are uploaded afterwards.

This means new packages will be in the index, but not downloadable.

I think that's terrible.

This could be fixed by carefully choosing the order in which files are updated. It can also be fixed by normal `apt-mirror` users by keeping a consistent snapshot of the repo available and switching to a new state only if that state is consistent.

Here's how to do that with glorious bash. Oh, and zfs snapshots - but that's an unimportant detail that could be easily implemented some other way.

I made a gist that contains [both scripts](https://gist.github.com/duk3luk3/8e3e88d6d77e7b6f089e00f7c1705612). Read below for explanations.

## The verification script

This script is set as `post_mirror` script for apt-mirror:

    #!/bin/bash
    
    basedir=/srv/ubuntumirror
    
    ret=0
    newfiles=$(wc -l $basedir/var/NEW | grep -o '^[0-9]\+')
    if [[ "0" == $newfiles && "$1" != "force" ]]
    then 
    	echo "No new files"
    else
    	echo "Checking Package list files"
    	for i in $basedir/mirror/de.archive.ubuntu.com/ubuntu/dists/*; do
    	(
    	cd $i
    	pmis=$(tail -n +11 Release | egrep '^ [a-z0-9]{32} ' | grep -v -e '-\(powerpc\|sparc\|ia64\|armel\|armhf\|ppc64el\|arm64\|s390x\)\(/\|\.\|$\)' -e '\(Contents\|Components\)-[^.]\+\(\.yml\)\?$' -e '\.tar$' -e '/debian-installer/' -e '/i18n/\(Translation\|Index\)' | awk '{print $1" "$3}' | md5sum -c --quiet 2>&1 )
    	pmisfiles=$(echo "$pmis" | sed '/^$/d' | wc -l)
    	if [[ "0" == $pmisfiles ]]
    	then
    		echo "All package list files good in $(basename $i)"
    		exit 0
    	else
    		echo "$pmisfiles Bad package list files in $(basename $i):"
    		echo "$pmis"
    		exit 1
    	fi
    	) || ret=1
    	done
    	cd $basedir/mirror
    	newfiles=$(wc -l $basedir/var/NEW | grep -o '^[0-9]\+')
    	if [[ "0" == $newfiles ]]
    	then
    		echo "No new package files"
    	else
    		mismatch=$(cut -b"8-" $basedir/var/NEW | xargs -I '{}' -n 1 grep -F "{}" $basedir/var/MD5 | md5sum --quiet -c 2>&1 )
    		#echo "$mismatch"
    		mismatchfiles=$(echo "$mismatch" | sed '/^$/d' | wc -l)
    		if [[ "0" == $mismatchfiles ]]
    		then
    			echo "All $newfiles new package files good"
    		else
    			echo "$newfiles new package files, but $mismatchfiles bad files:"
    			echo "$mismatch"
    			ret=1
    		fi
    	fi
    fi
    if [[ "0" == $ret ]]; then
    	touch /srv/ubuntumirror/SUCCESS
    fi
    echo "postmirror done at $(date)"
    exit $ret

It does the following things:

1. Check if there are new files by checking the `var/NEW` file left by `apt-mirror`
2. Parse the `Release` file for md5sum's of all `Contents-$arch`, `Components-$arch`, and `Packages` files that you care about and test them
3. Get the md5sum of all files in `var/NEW` from `var/MD5` and check them
4. If both checks succeed, touch a `SUCCESS` sentinel file

## The cron script

This script should be run from cron every 4 hours, as the package mirror guidelines suggest.

    #!/bin/bash
    
    echo "apt-mirror start: $(date)"
    
    args=$(getopt -l "initial,config:" -o "i,c:" -- "$@")
    
    eval set -- "$args"
    
    initial=0
    config=/etc/apt/mirror.list
    
    while [ $# -ge 1 ]; do
    	case "$1" in
    		--)
    		    # No more options left.
    		    shift
    		    break
    		   ;;
    		-i|--initial)
    			initial=1
    			shift
    			;;
    		-c|--config)
    			config="$2"
    			shift
    			;;
    	esac
    
    	shift
    done
    
    if pgrep apt-mirror >/dev/null; then
    	killall apt-mirror
    	echo "Killed running apt-mirror"
    
    #	echo "Saving state..."
    #	name="dist-bak-$(date +%s)"
    #	mkdir -p /srv/ubuntumirror/backups/$name
    #	cp -r /srv/ubuntumirror/mirror/de.archive.ubuntu.com/ubuntu/dists /srv/ubuntumirror/backups/$name
    #	echo "Done, old state saved to /srv/ubuntumirror/backups/$name"
    
    fi
    if [[ $initial == 1 ]]; then
    	echo "Initial run, removing SUCCESS sentinel"
    	[ -e /srv/ubuntumirror/SUCCESS ] && rm /srv/ubuntumirror/SUCCESS
    fi
    
    echo "Running apt-mirror from $config"
    echo "Running apt-mirror from $config at $(date)" >>/var/log/apt/mirror.cronstderr.log
    APTMIRROUT=$(/usr/local/bin/apt-mirror $config 2>>/var/log/apt/mirror.cronstderr.log | tee -a /var/log/apt/mirror.cron.log)
    
    # create snapshot
    SNAPSHOTLOC="/srv/ubuntumirror/.zfs/snapshot/$(date +%s)"
    echo "Creating snapshot in $SNAPSHOTLOC"
    mkdir $SNAPSHOTLOC
    
    echo "apt-mirror finish: $(date)"
    
    if [ -e /srv/ubuntumirror/SUCCESS ]
    then
    	echo "Success - pointing webserver at snapshot"
    	rm /var/www/ubuntu
    	ln -s $SNAPSHOTLOC/mirror/de.archive.ubuntu.com/ubuntu /var/www/ubuntu
    else
    	echo "Fail - check logs" >&2
    	echo "$APTMIRROUT" >&2
    fi

This script accomplishes the following:

1. Scan for `-i` and `-c` options
2. Kill any running `apt-mirror` instance
3. Removing the `SUCCESS` sentinel
4. Running apt-mirror
5. Creating a zfs snapshot of the result of apt-mirror
6. If the sentinel was set by apt-mirror (to be precide, apt-mirror's `post_mirror` script that we see above), update the web server to serve from the snapshot.

This way, the mirror will always be consistent.

If you don't have ZFS, you will have to use a different method of making snapshots (for example using `cp -al` - see e.g. here: [www.mikerubel.org/computers/rsync_snapshots/](http://www.mikerubel.org/computers/rsync_snapshots/)).
