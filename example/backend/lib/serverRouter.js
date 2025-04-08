const express = require('express');
const path = require('path');
const pool = require('./pool');
const { executeQuery, executeAtomicQuery } = require('./queryTool');
const queryTemplates = require('./rawQueryTemplates.json');
const { fetchExternalData } = require("./fetchExternalData");
const inputConfig = require('./inputConfig');

function initServerRoutes(app, routesConfig = []) {

  app.use(express.json());

  // when server is up, can test in Postman etc that DB is connected - returns time now (GET in http://localhost:3000/test)
  app.get('/test', async (req, res) => {

    try {
      const result = await pool.query('SELECT NOW()');
      res.json({ dbTime: result.rows[0].now });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }

  });

  // user-defined routes
  routesConfig.forEach((route) => {

    const { method, path, handler } = route;
    // attaching routes to express router
    app[method.toLowerCase()](path, handler);

  });

  // nav build routes - sanitized to only include routes which should be in nav
  app.get('/nav-routes', (req, res) => {

    // filters out sensitive or irrelevant fields
    const safeRoutes = routesConfig
      .filter(r => r.inNav)
      .map(({ path, label }) => ({ path, label })); 
    
      // then we only return path and label, or could expand with more attributes

    res.json(safeRoutes);

  });

  // safety catch-all root route when it is not defined by the user/engineer
  // commenetd out to be sure that routesConfig works
  // const hasRootRoute = routesConfig.some(r => r.path === '/');
  // if (!hasRootRoute) {

  //   // Hard-code or provide a config-based path to index.html
  //   app.get('/', (req, res) => {
  //     // std "home"
  //     res.sendFile(path.join(__dirname, '../../example/frontend/index.html'));

  //   });

  // }

  // MOVING THIS BEFORE THE NEXT AS IT CAN MATCH TO NEXT OTHERWISE IN EXPRESS.
  // Should parameterise and/or make the path unique for id fetcher
  // defiing the actual post from db and used by getActivePostId() helper in index.js
  app.get('/api/query/fetchEditDraftPost', async (req, res) => {
  
    try {
  
      const sqlQuery = queryTemplates.queries.fetchEditDraftPost.query;

      console.log("Available query keys:", Object.keys(queryTemplates.queries));
      console.log("Requested query key:", "fetchEditDraftPost");

      if (!sqlQuery) {
        return res.status(400).json({ error: "Query template not found" });
      }

      const result = await executeQuery(sqlQuery);

      console.log("Fetched Draft Post:", result);

      if (!result.length || !result[0].content) {
        return res.status(404).json({ error: "No active post in edit_draft or content missing" });
      }

      res.json({ postId: result[0].id, content: result[0].content });

    } catch (error) {
  
      console.error("Error fetching active edit draft post:", error);
      res.status(500).json({ error: "Failed to fetch edit draft post" });
  
    }
  
  });

  // query endpoint - where queryKey is used to define ASC or DESC for raw SQL in LIMIT example
  app.get('/api/query/:queryKey', async (req, res) => {
  
    let queryKey = req.params.queryKey;
    
    // extracting the sortOrder for ASC and DESC for raw SQL via key
    // have to check/test later if need to have a decision matrix like this for more complex SQL queries - sort of a middleware approach - as raw as possible, but keeps SQL less complex, when can call from raw queries based on key
    const { sortOrder, minRating, maxRating, limit } = req.query;
    const selectedQueryKey = sortOrder === "ASC" ? `${queryKey}ASC` : `${queryKey}DESC`;

    const queryConfig = queryTemplates.queries[selectedQueryKey];
    if (!queryConfig) {
      return res.status(400).json({ error: "Invalid query key" });
    }

    const params = [minRating, maxRating, limit];

    try {
      
      const start = process.hrtime();
      
      const result = await executeQuery(queryConfig.query, params);

      const end = process.hrtime(start);
      const durationMs = (end[0] * 1000 + end[1] / 1e6).toFixed(3);

      res.json({ data: result, executionTime: `${durationMs} ms` }); // send execution time too.

    } catch (error) {
      
      console.error("Query Execution Failed:", error);
      res.status(500).json({ error: "Query execution failed" });

    }
  
  });

  // external api route for the ISS location example atm
  app.get("/api/external/iss", async (req, res) => {

    const data = await fetchExternalData("http://api.open-notify.org/iss-now.json");
    res.json(data);
    
  });

  // drafts page DB table validation
  app.get('/api/drafts/state', async (req, res) => {

    try {

      // state is deifned and post tracking is benchmarked by knowing the count in all 3 tables per post
      const sqlQuery = queryTemplates.queries.fetchDraftState.query;

      if (!sqlQuery) {
        return res.status(400).json({ error: "Query template not found" });
      }

      const result = await executeQuery(sqlQuery);
      const { draft_count, edit_count, published_count } = result[0];

      res.json({

        // Movement tracking
        draft_storage: draft_count,
        edit_draft: edit_count,
        published_posts: published_count,

      });

    } catch (error) {

      console.error("Failed to fetch state:", error);
      res.status(500).json({ error: "Failed to retrieve state" });

    }

  });

  // drafts page buttons state DB validation
  app.get('/api/drafts/buttonstate', async (req, res) => {

    try {

      const sqlQuery = queryTemplates.queries.fetchButtonStates.query;

      if (!sqlQuery) {
        return res.status(400).json({ error: "Query template not found" });
      }

      const result = await executeQuery(sqlQuery);

      // rough fallbacks
      if (!result || !result.length) {
        return res.json({
          enable_add_post: false,
          enable_save: false,
          enable_edit_latest: false,
          enable_publish: false,
          enable_add_timestamp: false,
          enable_delete_all: false
        });
      }

      const row = result[0];
      res.json({

        draft_count: row.draft_count,
        edit_count: row.edit_count,
        published_count: row.published_count,

        enable_add_post: row.enable_add_post,
        enable_save: row.enable_save,
        enable_publish: row.enable_publish,
        enable_add_timestamp: row.enable_add_timestamp,
        enable_edit_latest: row.enable_edit_latest,
        enable_delete_all: row.enable_delete_all,
        
      });

    } catch (error) {

      console.error("Failed to fetch button state:", error);
      res.status(500).json({ error: "Failed to retrieve button state" });

    }

  });

  // create post in Drafts page
  app.post('/api/query/createPost', async (req, res) => {
  
    try {

      const isAllowed = await validateAction(req);
      if (!isAllowed) {
        return res.status(403).json({ error: "Action not allowed by DB state" });
      }
  
      const sqlQuery = queryTemplates.queries.createPost.query;
      const result = await executeQuery(sqlQuery);

      if (!result.length || !result[0].id) {
        return res.status(500).json({ error: "Post creation failed" });
      }

      res.json({ postId: result[0].id, content: result[0].content });

    } catch (error) {
  
      console.error("Error creating post:", error);
      res.status(500).json({ error: "Failed to create post" });
  
    }
  
  });

  // save a post == move to draft storage table
  app.post('/api/query/moveToDrafts', async (req, res) => {

    try {

      const isAllowed = await validateAction(req);
      if (!isAllowed) {
        return res.status(403).json({ error: "Action not allowed by DB state" });
      }

      const { id, content } = req.body;

      // validating the input via inputConfig
      let validatedContent;
      try {

        validatedContent = inputConfig.validateContent({ content });

      } catch (validationError) {

        console.error("Validation failed:", validationError.message);
        return res.status(400).json({ error: "Invalid content format." });

      }

      // sequence stack from raw templates dictates the flow for the query tool after input is already validated
      const result = await executeAtomicQuery("atomicMoveToDrafts", { id, content: validatedContent });

      if (!result || result.length === 0) {
        return res.status(500).json({ error: "Move to drafts failed" });
      }      

      res.json({ success: true, draftId: result[0].id });

    } catch (error) {

      console.error("Error moving post to drafts:", error);
      res.status(500).json({ error: "Failed to save post" });

    }

  });

  // publish a post == move the post to plublished post table
  app.post('/api/query/moveToPublished', async (req, res) => {
  
    try {

      const isAllowed = await validateAction(req);
      if (!isAllowed) {
        return res.status(403).json({ error: "Action not allowed by DB state" });
      }
  
      const { id, content } = req.body;

      // validating the input via inputConfig
      let validatedContent;
      try {

        validatedContent = inputConfig.validateContent({ content });

      } catch (validationError) {

        console.error("Validation failed:", validationError.message);
        return res.status(400).json({ error: "Invalid content format." });

      }

      // sequence stack from raw templates dictates the flow for the query tool after input is already validated
      const result = await executeAtomicQuery("atomicMoveToPublished", { id, content: validatedContent });

      if (!result || result.length === 0) {
        return res.status(500).json({ error: "Move to published failed" });
      }

      res.json({ success: true, publishedId: result[0].id });

    } catch (error) {
  
      console.error("Error publishing post:", error);
      res.status(500).json({ error: "Failed to publish post" });
  
    }
  
  });

  // edit latest == getting get the latest post from draft_storage or published_posts back to edit_draft table
  app.post('/api/query/editLatestPost', async (req, res) => {
  
    try {

      const isAllowed = await validateAction(req);
      if (!isAllowed) {
        return res.status(403).json({ error: "Action not allowed by DB state" });
      }
  
      const result = await executeAtomicQuery("atomicMoveLatestToEditDraft", {});

      if (!result || result.length === 0) {
        return res.status(404).json({ error: "No editable post found." });
      }

      res.json({ postId: result[0].id, content: result[0].content });

    } catch (error) {
  
      console.error("Error moving latest post to edit mode:", error);
      res.status(500).json({ error: "Failed to edit latest post" });

    }
  
  });

  // delete all
  app.post('/api/query/deleteAllPosts', async (req, res) => {

    try {

      /*
      For this example, delecting a certain post is not important, so we can delete all posts.
      So we do not use a raw query from templates, and invoke a delete function stored in the DB itself.
      Could call the function directoy too (await executeQuery("SELECT delete_all_posts();");) ut keeping SQL out of procedural code.
      Does hide the logic a bit, but even more "raw" and even less procedural code:

      CREATE OR REPLACE FUNCTION delete_all_posts()
      RETURNS void AS $$
      BEGIN
          DELETE FROM draft_storage;
          DELETE FROM edit_draft;
          DELETE FROM published_posts;
      END;
      $$ LANGUAGE plpgsql;

      */
     
      const startTime = process.hrtime();

      const isAllowed = await validateAction(req);
      if (!isAllowed) {
        return res.status(403).json({ error: "Action not allowed by DB state" });
      }

      const sqlQuery = queryTemplates.queries.deleteAllPosts.query;
      await executeQuery(sqlQuery);

      const endTime = process.hrtime(startTime);
      const durationMs = (endTime[0] * 1000 + endTime[1] / 1e6).toFixed(3);

      console.log(`Post deletion executed successfully in ${durationMs} ms.`);

      res.json({ success: true, executionTime: `${durationMs} ms` });

    } catch (error) {
      
      console.error("Error deleting posts:", error);
      res.status(500).json({ error: "Failed to delete posts" });

    }

  });

  // extracting db-enforced validation "checksums" from API endpoints, so validation works as an universal nested helper together with this helper
  async function validateAction(req) {
  
    // extracts the last part of the API endpoint like "moveToPublished" etc
    const actionType = req.path.split('/').pop();

    const validationQuery = queryTemplates.queries.validateActionAllowed.query;
    const result = await executeQuery(validationQuery, [actionType]);

    return result.length > 0 && result[0].allowed === true;
  
  }

  // Access page example 1
  app.get('/api/access/relations', async (req, res) => {

    try {
        
      const sqlQuery = queryTemplates.queries.fetchUserRelations.query;
        
      if (!sqlQuery) {
        return res.status(400).json({ error: "Query template not found" });
      }

      const result = await executeQuery(sqlQuery);

      if (!result.length) {
        return res.json({ message: "No relationships found.", data: [] });
      }

      // frontend response - puerly for presentation, as have to "translate" the state to a showable value.
      // fetchUserRelations would have a bit different structure when set up for triggering actions.
      const packagedResponse = result.map(row => ({
        user_id: row.user_id,
        username: row.username,
        other_user_id: row.other_user_id,
        other_username: row.other_username,
        relation_type: row.relation_type,
        block_status: row.block_status
      }));

      res.json({ query: sqlQuery, data: packagedResponse });

    } catch (error) {

      console.error("Error fetching user relations:", error);
      res.status(500).json({ error: "Failed to retrieve user relations" });

    }

  });

  // Access page example 2
  app.get('/api/access/relations2', async (req, res) => {

    try {
        
      const sqlQuery = queryTemplates.queries.fetchUserRelations2.query;
        
      if (!sqlQuery) {
        return res.status(400).json({ error: "Query template not found" });
      }

      const result = await executeQuery(sqlQuery);

      if (!result.length) {
        return res.json({ message: "No relationships found.", data: [] });
      }

      // frontend response - puerly for presentation, as have to "translate" the state to a showable value.
      // fetchUserRelations would have a bit different structure when set up for triggering actions.
      const packagedResponse = result.map(row => ({
        user_id: row.user_id,
        username: row.username,
        other_user_id: row.other_user_id,
        other_username: row.other_username,
        relation_type: row.relation_type,
        block_status: row.block_status
      }));

      res.json({ query: sqlQuery, data: packagedResponse });

    } catch (error) {

      console.error("Error fetching user relations:", error);
      res.status(500).json({ error: "Failed to retrieve user relations" });

    }

  });

  // Access page example 3
  app.get('/api/access/relations3', async (req, res) => {

    try {
        
      const sqlQuery = queryTemplates.queries.fetchUserRelations3.query;
        
      if (!sqlQuery) {
        return res.status(400).json({ error: "Query template not found" });
      }

      const result = await executeQuery(sqlQuery);

      if (!result.length) {
        return res.json({ message: "No relationships found.", data: [] });
      }

      // frontend response - puerly for presentation, as have to "translate" the state to a showable value.
      // fetchUserRelations would have a bit different structure when set up for triggering actions.
      const packagedResponse = result.map(row => ({
        user_id: row.user_id,
        username: row.username,
        other_user_id: row.other_user_id,
        other_username: row.other_username,
        relation_type: row.relation_type,
        block_status: row.block_status
      }));

      res.json({ query: sqlQuery, data: packagedResponse });

    } catch (error) {

      console.error("Error fetching user relations:", error);
      res.status(500).json({ error: "Failed to retrieve user relations" });

    }

  });

  // example block 2 in Access page
  app.get('/api/access/permissions', async (req, res) => {

    try {

      const sqlQuery = queryTemplates.queries.fetchAccessPermissions.query;

      if (!sqlQuery) {
        return res.status(400).json({ error: "Query template not found" });
      }

      const result = await executeQuery(sqlQuery);

      if (!result.length) {
        return res.json({ message: "No access records found.", data: [] });
      }

      // for presentation
      const packagedResponse = result.map(row => ({
        username: row.username,
        space_name: row.space_name,
        access_status: row.access_status,
        has_valid_permission_log: row.has_valid_permission_log
      }));

      res.json({ query: sqlQuery, data: packagedResponse });

    } catch (error) {

      console.error("Error fetching access permissions:", error);
      res.status(500).json({ error: "Failed to retrieve access permissions" });

    }

  });

  // static file rough serving
  app.use(express.static(path.join(__dirname, '../../frontend'))); // relative path (from lib)
  app.use('/partials', express.static(path.join(__dirname, '../../frontend/partials')));

  console.log("Routes initialized.");

}

module.exports = { initServerRoutes };