--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import Data.Monoid (mappend, mconcat)
import Data.Maybe (fromMaybe)
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

    match "static_html/*" $ do
        route   $ setExtension "html" `composeRoutes` gsubRoute "static_html/" (const "")
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "static/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "posts/**" $ do
        route $ setExtension "html" `composeRoutes` (gsubRoute ".*/" (const "posts/")) 
        compile $ do
        
            pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    (postCtx tags)
                >>= loadAndApplyTemplate "templates/default.html" (postCtx tags)
                >>= relativizeUrls

--    match "posts/**" $ do
--        route $ setExtension "html"
--        compile $ 

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/**"
            let archiveCtx = mconcat [
                    listField "posts" (postCtx tags) (return posts),
                    constField "title" "Archives",
                    defaultContext
                    , tagCloudCtx tags ]

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    create ["archive2.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/**"
            categories <- buildCategories "posts/**" (fromCapture "posts/*.html")
            let categoryMap = tagsMap categories
            let categoryPatterns = map \(s,i)->(s, fromList i) categoryMap
            let archiveCtx = mconcat [
                    listField "categories" (postCtx tags) (return categoryMap)
                    , constField "title" "Archives"
                    , defaultContext
                    , tagCloudCtx tags ]

            makeItem ""
                >>= loadAndApplyTemplate "templates/post-by-category.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    tagsRules tags $ \tag pattern -> do
        let title = "Tagged: " ++ tag
        route idRoute
        compile $ do
            posts <- constField "posts" <$> postList pattern (postCtx tags) recentFirst

            makeItem ""
                >>= loadAndApplyTemplate "templates/posts.html" posts
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/**"
            --cats <- buildCategories "posts/**"

            let indexCtx =
                    listField "posts" (postCtx tags) (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
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

-- | Creates a compiler to render a list of posts partitioned by categories
categoryList :: Tags
             -> Context String
             -> ([Item String] -> Compiler [Item String])
             -> Compiler String
categoryList categories postCtx sortFilter = do
-- what now?

-- | Creates a compiler to render a post list with a category headline
categoryPostList :: Pattern
                 -> String
                 -> Context String
                 -> ([Item String] -> Compiler [Item String])
                 -> Compiler String
categoryPostList pattern catname postCtx sortFilter = do
    posts <- sortFilter =<< loadAll pattern
    catTpl <- loadBody "templates/post-by-category.html"
    itemTpl <- loadBody "templates/post-item.html"
    let catCtx = mconcat [
      constField "category" catname
      , defaultCtx
    ]
    applyTemplateList itemTpl postCtx posts
    >== applyTemplate catTpl catCtx



categoryPattern :: Tags -> String -> Pattern
categoryPattern map name =
    fromList $ fromMaybe [] $ lookup name map

--catOnly :: MonadMetadata m => Tags -> [Item a] -> m [Item a]
--catOnly cats = 


--catPosts pattern postCtx category = postList pattern postCtx (\post -> getCategory post == category)
