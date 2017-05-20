--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import Data.Monoid (mappend, mconcat)
import Control.Applicative
import Hakyll
import Hakyll.Web.Tags


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do

    tags <- buildTags "posts/**" (fromCapture "tags/*.html")
    categories <- buildCategories "posts/**" (fromCapture "posts/*.html")

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "static_html/*.en.*" $ do
        route   $ setExtension "html" `composeRoutes` gsubRoute "static_html/" (const "")
        compile $ do
            let langCtx =
                    constField "lang" "en"                `mappend`
                    constField "alt_lang" "de"          `mappend`
                    nameField "name"                      `mappend`
                    defaultContext

            pandocCompiler
                >>= loadAndApplyTemplate "templates/default.en.html" langCtx
                >>= relativizeUrls

    match "static_html/*.de.*" $ do
        route   $ setExtension "html" `composeRoutes` gsubRoute "static_html/" (const "")
        compile $ do
            let langCtx =
                    constField "lang" "de"                `mappend`
                    constField "alt_lang" "en"          `mappend`
                    nameField "name"                      `mappend`
                    defaultContext

            pandocCompiler
                >>= loadAndApplyTemplate "templates/default.de.html" langCtx
                >>= relativizeUrls

    match (fromRegex "^static_html/[^.]*[.][^.]*$") $ do
        route   $ setExtension "html" `composeRoutes` gsubRoute "static_html/" (const "")
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.en.html" defaultContext
            >>= relativizeUrls

    match "static/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "posts/**.en.md" $ do
        route $ setExtension "html" `composeRoutes` (gsubRoute ".*/" (const "posts/"))
        compile $ do
            let langCtx =
                    constField "lang" "en"                `mappend`
                    constField "alt_lang" "de"          `mappend`
                    nameField "name"                      `mappend`
                    postCtx tags

            pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    (langCtx)
                >>= loadAndApplyTemplate "templates/default.en.html" (langCtx)
                >>= relativizeUrls

    match "posts/**.de.md" $ do
        route $ setExtension "html" `composeRoutes` (gsubRoute ".*/" (const "posts/")) 
        compile $ do
            let langCtx =
                    constField "lang" "de"                `mappend`
                    constField "alt_lang" "en"          `mappend`
                    nameField "name"                      `mappend`
                    postCtx tags

            pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    (langCtx)
                >>= loadAndApplyTemplate "templates/default.de.html" (langCtx)
                >>= relativizeUrls

--    match "posts/**" $ do
--        route $ setExtension "html"
--        compile $ 

    create ["archive.en.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/**.en.*"
            categories <- buildCategories "posts/**.en.*" (fromCapture "posts/*.html")
            let categoryMap = tagsMap categories
            let archiveCtx = mconcat [
                    tagCloudCtx tags,
                    listField "posts" (postCtx tags) (return posts),
                    constField "title" "Archives",
                    constField "lang" "en",
                    constField "alt_lang" "de",
                    nameField "name",
                    defaultContext
                    ]
            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.en.html" archiveCtx
                >>= relativizeUrls

    create ["archive.de.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/**.de.*"
            categories <- buildCategories "posts/**.de.*" (fromCapture "posts/*.html")
            let categoryMap = tagsMap categories
            let archiveCtx = mconcat [
                    tagCloudCtx tags,
                    listField "posts" (postCtx tags) (return posts),
                    constField "title" "Archiv",
                    constField "lang" "de",
                    constField "alt_lang" "en",
                    nameField "name",
                    defaultContext
                    ]
            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.de.html" archiveCtx
                >>= relativizeUrls

--    create ["archive2.html"] $ do
--        route idRoute
--        compile $ do
--            --posts <- recentFirst =<< loadAll "posts/**"
--            --categories <- buildCategories "posts/**" (fromCapture "posts/*.html")
--            --let categoryMap = tagsMap categories
--            let archiveCtx = mconcat [
--            --        listField "categories" (postCtx tags) (return categoryMap),
--                    constField "title" "Archives",
--                    defaultContext
--                    , tagCloudCtx tags ]
--
--            makeItem ""
--                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
--                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
--                >>= relativizeUrls

    tagsRules tags $ \tag pattern -> do
        let title = "Tagged: " ++ tag
        route idRoute
        compile $ do
            posts <- constField "posts" <$> postList pattern (postCtx tags) recentFirst

            makeItem ""
                >>= loadAndApplyTemplate "templates/posts.html" posts
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls


    match "index.en.md" $ do
        route   $ setExtension "html"
        compile $ do
            posts <- recentFirst =<< loadAll "posts/**.en.*"

            let indexCtx = mconcat [
                    listField "posts" (postCtx tags) (return posts),
                    constField "lang" "en",
                    constField "alt_lang" "de",
                    nameField "name",
                    defaultContext
                    ]

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= renderPandoc
                >>= loadAndApplyTemplate "templates/default.en.html" indexCtx
                >>= relativizeUrls

    match "index.de.md" $ do
--        route idRoute
        route   $ setExtension "html"
        compile $ do
            posts <- recentFirst =<< loadAll "posts/**.de.*"

            let indexCtx = mconcat [
                    listField "posts" (postCtx tags) (return posts),
                    constField "lang" "de",
                    constField "alt_lang" "en",
                    nameField "name",
                    defaultContext
                    ]

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= renderPandoc
                >>= loadAndApplyTemplate "templates/default.de.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Tags -> Context String
postCtx tags = mconcat 
    [ dateField "date" "%B %e, %Y"
    , tagsField "tags" tags
    , defaultContext
    ]

tagCloudCtx :: Tags -> Context String
tagCloudCtx tags = field "tagcloud" $ \item -> rendered
    where rendered = renderTagCloud 85.0 165.0 tags

-- | Creates a compiler to render a list of posts for a given pattern, context,
-- and sorting/filtering function
postList :: Pattern
         -> Context String
         -> ([Item String] -> Compiler [Item String])
         -> Compiler String
postList pattern postCtx sortFilter = do
    posts <- sortFilter =<< loadAll pattern
    itemTpl <- loadBody "templates/post-item.html"
    applyTemplateList itemTpl postCtx posts

nameField :: String -> Context a
nameField key = field key $ return . lastSlash . firstSplit . toFilePath . itemIdentifier

dotSplit :: String -> [String]
dotSplit = splitAll "[.]..[.]"

slashSplit :: String -> [String]
slashSplit = splitAll "/"

firstSplit :: String -> String
firstSplit = head . dotSplit

lastSlash :: String -> String
lastSlash = last . slashSplit


--catOnly :: MonadMetadata m => Tags -> [Item a] -> m [Item a]
--catOnly cats = 


--catPosts pattern postCtx category = postList pattern postCtx (\post -> getCategory post == category)
