# Framework documentation

Here you will find the documentation for:
- Setup (and optionally test data for the example project)
- Tools and usage ideas

Recommendation for usage and studying the patterns:
- To set up a DB and insert the test data
- This would allow to follow and test and experiment with the IoC patterns and to discover effectively how to work with this or around this.
- The project is not a prebuilt library of components, but rather a frameworky set of tools with freedom of execution to implement changes as one sees fit - like a donk version of Django with some presets, but up to the user to choose what they want to keep, etc.
- The essense of the project is a full web framework where the most valuable part of any application (the data and db) controls and orchestrates everything. Backend and frontend facilitate.

## Setup:

### Prequisities after cloning the repo:
 - Node.js
 - Postgres database

### install dependencies:
```
cd example/backend
npm install
```

IRL, if would not have framework tools pulled to example, then would also run "npm run build" which is in the package.json file in: example/backend/package.json. But no need atm, as kept the files for a working example.

### Create a postgres db:
- Do a std postgres install and generate the creds.
- Place your DB creds into: example/.env (these will be used in the pool)

### Optional - Create the DB Schema to make the prebuilt examples work:

- If you want to test the working example on your database too insetad of just studying code and docs, then enter psql via CLI in root of the project where your DB is placed normally with this command in (swap placeholder values to ones you added to .env for yoru db):
  ```
  psql -U username -d database name
  ```
- then run the following commands in psql to add tables and test data:

### For Limit example with movielens data:

```sql
CREATE TABLE movies (
  movieId INTEGER PRIMARY KEY,
  title TEXT,
  genres TEXT  -- pipe-separated
);

CREATE TABLE ratings (
  userId INTEGER,
  movieId INTEGER,
  rating NUMERIC(2,1),
  timestamp BIGINT,
  PRIMARY KEY (userId, movieId),
  FOREIGN KEY (movieId) REFERENCES movies(movieId)
);

-- data from MovieLens

\copy movies(movieId, title, genres)
  FROM './zzzzz_exampledata/movies.csv'
  DELIMITER ',' CSV HEADER;

\copy ratings(userId, movieId, rating, timestamp)
  FROM './zzzzz_exampledata/ratings.csv'
  DELIMITER ',' CSV HEADER;

-- Checking that it worked:

SELECT COUNT(*) FROM movies; -- or just *
SELECT COUNT(*) FROM ratings; -- or just *

-- or just chekc you have tables with the following command in psql:

\dt
```

### For Drafts example (data will be created by actions):

```sql
CREATE TABLE public.draft_storage (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    edited_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE public.edit_draft (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    edited_at TIMESTAMP DEFAULT now(),
    is_active BOOLEAN DEFAULT true
);

-- UNIQUE CONSTRAINT - ensures only one active edit draft at a time
CREATE UNIQUE INDEX single_active_edit ON public.edit_draft (is_active)
WHERE is_active = true;

CREATE TABLE public.published_posts (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    edited_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- in-db func: delete_all_posts() (it clears all stored posts)
CREATE FUNCTION public.delete_all_posts() RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM draft_storage;
    DELETE FROM edit_draft;
    DELETE FROM published_posts;
END;
$$;
```

### For Access example (this needs duplication of tables to run all scenarios):
#### DB state 1:

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE interests (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  interested_in INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT unique_interest UNIQUE (user_id, interested_in)
);

CREATE TABLE rejections (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rejected_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT unique_rejection UNIQUE (user_id, rejected_id)
);

-- Example data
INSERT INTO users (username)
VALUES ('A'), ('B');

INSERT INTO interests (user_id, interested_in) 
VALUES
  (1, 2);
```

#### DB state 2:

```sql
CREATE TABLE users2 (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE interests2 (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  interested_in INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT unique_interest2 UNIQUE (user_id, interested_in)
);

CREATE TABLE rejections2 (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rejected_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT unique_rejection2 UNIQUE (user_id, rejected_id)
);

-- Example data

INSERT INTO users2 (username)
VALUES ('A'), ('B');

INSERT INTO interests2 (user_id, interested_in) 
VALUES
  (1, 2), (2, 1);
```

#### DB state 3:

```sql
CREATE TABLE users3 (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE interests3 (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  interested_in INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT unique_interest3 UNIQUE (user_id, interested_in)
);

CREATE TABLE rejections3 (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rejected_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT unique_rejection3 UNIQUE (user_id, rejected_id)
);

-- Example data

INSERT INTO users3 (username)
VALUES ('A'), ('B');

INSERT INTO interests3 (user_id, interested_in) 
VALUES
  (1, 2);

INSERT INTO rejections3 (user_id, rejected_id)
VALUES
  (2, 1);
```

#### Admin permissions example:

```sql
CREATE TABLE users_access (
  id SERIAL PRIMARY KEY,
  username TEXT NOT NULL UNIQUE
);

CREATE TABLE admins (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users_access(id) ON DELETE CASCADE,
  owns_space TEXT NOT NULL
);

CREATE TABLE spaces (
  id SERIAL PRIMARY KEY,
  space_name TEXT NOT NULL UNIQUE
);

CREATE TABLE permissions (
  id SERIAL PRIMARY KEY,
  space TEXT REFERENCES spaces(space_name) ON DELETE CASCADE,
  user_with_access INT REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE permissions_log (
  id SERIAL PRIMARY KEY,
  admin_user INT REFERENCES users_access(id) ON DELETE CASCADE,
  granted_user INT REFERENCES users_access(id) ON DELETE CASCADE,
  space TEXT REFERENCES spaces(space_name) ON DELETE CASCADE,
  timestamp TIMESTAMP DEFAULT NOW()
);

-- Example data
INSERT INTO users_access (username) VALUES 
('A'),
('B');

INSERT INTO spaces (space_name) VALUES 
('A1');

INSERT INTO admins (user_id, owns_space) 
VALUES ((SELECT id FROM users_access WHERE username = 'A'), 'A1');

INSERT INTO permissions (space, user_with_access)
VALUES ('A1', (SELECT id FROM users WHERE username = 'B'));

INSERT INTO permissions_log (admin_user, granted_user, space)
VALUES (
  (SELECT id FROM users_access WHERE username = 'A'),
  (SELECT id FROM users_access WHERE username = 'B'),
  'A1'  
);
```

### Start the server:
```
npm start
```
Page can be accessed at: http://localhost:3000/

##  Tools and usage ideas:

In framework the tools are placed in core_backend and core_frontend.
In example project the backend tools are (or should be) placed to backend/lib and frontend tools to frontend/lib.

### Main structure:

```
example/
│── backend/                # Backend API
│   ├── lib/                # Backend tools from framework
│   ├── server.js           # Express server
│   ├── routesConfig.js     # Routing definitions
│   ├── package.json        # NPM scripts
│── frontend/               # Frontend application
│   ├── lib/                # Frontend tools from framework
│   ├── partials/           # Partial html templates inserted for SPA requirements stuff
│   ├── index.js            # Client-side logic
│   ├── index.html          # Main html backbone for SPA stuff (for reqs)
│   ├── index.css           # Unified styling
│── framework/              # Framework core (mimics an npm package)
│   ├── core_backend/       # Backend tools
│   ├── core_frontend/      # Frontend tools
```

### Main files and usage examples:

Our example project gives full usage examples with inline comments where applicable. We will not add all code snippets to the documentation, as the example project does better work of showing the idea and patterns. But some ideas about usage:

### Backend:

#### framework/core_backend/pool.js

- Establishes a connection to PostgreSQL using connection pooling.
- Make sure to have dotenv and a .env in example/.env and store your db creds there. For example:
  ```
  DB_HOST=localhost
  DB_PORT=5432
  DB_NAME=framework_db
  DB_USER=framework_user
  DB_PASSWORD=your_pw
  PORT=3000
  ```
  ```js
  /*
  Pool for .env vars for the postgres connection - for server.js or alike
  */

  const { Pool } = require('pg');
  const dotenv = require('dotenv');
  const path = require('path'); 

  dotenv.config({ path: path.join(__dirname, '../../.env') });

  console.log("DB Connection Info:", {
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
  });

  const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
  });

  module.exports = pool;
  ```

#### example/backend/server.js

- Initializes Express, loads the serverRouter, and starts the server.
- Our server is very simple and mainly connects the serverRouter and routesConfig
- If rest of the structure is maintained, the not any work really needed there.

#### example/backend/routesConfig.js

- This is currently placed close to server in the same dir, but is also part of the framework tools.
- While it is out of scope of our db-driven main web-framework logic, it handles many of the frontendy dynamic required by the task. For example, it powers the dynamic nav builder and generates the base for pages, which get the SPA rendering.
- Mostly it defines application routes statically.
- Each route maps to a template and is registered automatically
- If you want to add a new page and a link to main nav, just make sure that inNav is set to true and you add a Label. If false, the page and nav link will not be added (for pages/routes not meant for users etc).
- Other half of page creation is handled in clientApp.js in frontend (Feel free to follow the patterns).
  ```js
  module.exports = [

      {
          method: 'GET',
          path: '/',
          inNav: true, // show in nav
          label: 'Home',
          handler: (req, res) => {
              // Serve the index page
              res.sendFile(path.join(__dirname, '../frontend/index.html'));
          }
      },
      {
          method: 'GET',
          path: '/secret-admin',
          inNav: false,  // dont' show in nav
          handler: (req, res) => {
              // Serve the index page
              res.sendFile(path.join(__dirname, '../frontend/index.html'));
          }
      },
      // {}, // add more
  ];
  ```

#### example/backend/lib/serverRouter.js

- Registers API routes dynamically, executes predefined SQL queries from "SQLJSON".
- Allows db-driven interactions while keeping SQL out of node code - this enforces a very strong IoC and also somehting which could be called something like PoC (Process of Control) - the data engineer who sets up the systems can make sure that non-SQL-inclined engineers will not meddle with SQL queries and DB logic inside node, as it will be isolated.
- serverRouter also has a test route set up to test the DB connection once server is up.
  ```js
  // when server is up, can test in Postman etc that DB is connected - returns time now (GET in http://localhost:3000/test)
    app.get('/test', async (req, res) => {

      try {
        const result = await pool.query('SELECT NOW()');
        res.json({ dbTime: result.rows[0].now });
      } catch (err) {
        res.status(500).json({ error: err.message });
      }

    });
  ```
- serverRouter also fetches queries from rawQueryTemplates.json and uses the querytool to execute queries. For example:
  ```js
  // query endpoint - where queryKey is used to define ASC or DESC for raw SQL in LIMIT example
  app.get('/api/query/:queryKey', async (req, res) => {
  
    let queryKey = req.params.queryKey;
    
    // extracting the sortOrder for ASC and DESC for raw SQL via key
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
  ```
- It is highly recommended to follow the data flow from DB to frontend and back, as the patterns are very unified for very different examples - should give a way better overview of how DB-first approach is enforced for simpler and more protected frontend and backend.
- External resources and APIs can be consumed similarly to this example in serverRouter (school requirement but not really a focus here):
  ```js
  // external api route for the ISS location example atm
  app.get("/api/external/iss", async (req, res) => {
    const data = await fetchExternalData("http://api.open-notify.org/iss-now.json");
    res.json(data);
  });
  ```
- which uses fetchExternalData.js:
  ```js
  async function fetchExternalData(url) {
      try {
          const fetch = (await import("node-fetch")).default; // dynamic import to avoid ES modules
          const response = await fetch(url);
          if (!response.ok) throw new Error(`HTTP error! Status: ${response.status}`);
          return await response.json();
      } catch (error) {
          console.error("Error fetching external API:", error);
          return { error: "Failed to retrieve external data" };
      }
  }

  module.exports = { fetchExternalData };
  ```

#### example/backend/lib/inputConfig.js

- It sanitizes and checks that DB does not have to deal with unintended or malicious input.
- Any new config should be mapped to its use case and built around the idea that you know the data format or values coming in, and everything else should thrown an error.
- While our goal is everything as DB-driven as possible, good sense is to keep crap out of DB before - thus in node.
- For example:
  ```js
  // timestamp mimics content, but is still input and form submission-like process, so should be ran through the conifg
    "validateContent": ({ content }) => {

        if (typeof content !== "string" || content.trim() === "") {
            throw new Error("Content must be a non-empty string.");
        }
        
        const parsedDate = Date.parse(content);
        
        if (isNaN(parsedDate)) {
            throw new Error("Content must be a valid timestamp.");
        }

        // just sort of enforcing some date operations like a donk-2FA in input validation
        const now = Date.now();
        const pastLimit = now - 180 * 24 * 60 * 60 * 1000; // 180 days ago
        const futureLimit = now + 1 * 24 * 60 * 60 * 1000; // 1 day ahead
        
        if (parsedDate < pastLimit || parsedDate > futureLimit) {
            throw new Error("Timestamp out of allowed range.");
        }

        return content.trim();

    }
  ```

#### example/backend/lib/queryTool.js

- queryTool provides 2 types of queries.
- executeQuery - for a straight simple query
- executeAtomicQuery - for atomic transactions, where any errors will mean that DB will roll back and any changes to DB will be controlled - all works or none works -> This in some sceanrios is extremely useful when actual true DB state defines a feature, like Drafts example where a post in edit mode means that post is moved to an edit_draft table from published_posts or draft_storage.
  ```js
  // For Drafts exmaple - thhe SQL+JSON structure controls what the tool does and could expand both so SQL still drives the process and queryTool just inferes what needs to happen etc.
  // need to return an actual result too - db still needs to be usable, not a vault.
  async function executeAtomicQuery(sequenceKey, providedParams) {

    const sequence = queryTemplates.querySequences[sequenceKey];

    if (!sequence) {

        throw new Error(`Query sequence '${sequenceKey}' not found`);

    }

    const client = await pool.connect();
    try {

        if (sequence.transaction) {

            await client.query("BEGIN"); // start transaction if needed

        }

        let finalResult = null; // result too

        for (const step of sequence.steps) {

            const queryConfig = queryTemplates.queries[step.queryKey];
            if (!queryConfig) {

                throw new Error(`Query key '${step.queryKey}' not found`);

            }

            // define parameters dynamically
            const queryParams = step.params.map(paramKey => providedParams[paramKey]);

            console.log(`Executing step: ${step.queryKey}`, queryParams);
            const queryResponse = await client.query(queryConfig.query, queryParams);
            finalResult = queryResponse.rows.length > 0 ? queryResponse.rows : finalResult;

        }

        if (sequence.transaction) {

            await client.query("COMMIT"); // commit transaction if applicable here

        }

        return finalResult;

    } catch (error) {

        if (sequence.transaction) {

            await client.query("ROLLBACK"); // atomic rollback on failure

        }
        
        console.error(`Query sequence '${sequenceKey}' failed:`, error);
        throw new Error("Query execution failed");

    } finally {

        client.release();

    }
  }
  ```

#### example/backend/lib/rawQueryTemplates.json

- this is what we call "SQLJSON" - it allows data engineers to keep SQL queries out of node code where page/app maintainers would do smaller or more cosmetic changes - quries are not fiddled with.
- Basically can write all raw SQL queries and place them into this JSON file.
  ```json
  "fetchButtonStates": {
      "query": "SELECT (SELECT COUNT(*) FROM draft_storage) AS draft_count, (SELECT COUNT(*) FROM edit_draft) AS edit_count, (SELECT COUNT(*) FROM published_posts) AS published_count, (SELECT COUNT(*) FROM edit_draft) = 0 AS enable_add_post, (SELECT COUNT(*) FROM edit_draft) = 1 AS enable_save, (SELECT COUNT(*) FROM edit_draft) = 1 AS enable_publish, (SELECT COUNT(*) FROM edit_draft) = 1 AS enable_add_timestamp, (SELECT COUNT(*) FROM edit_draft) = 0 AND ((SELECT COUNT(*) FROM draft_storage) > 0 OR (SELECT COUNT(*) FROM published_posts) > 0) AS enable_edit_latest, (SELECT COUNT(*) FROM draft_storage) + (SELECT COUNT(*) FROM edit_draft) + (SELECT COUNT(*) FROM published_posts) > 0 AS enable_delete_all"
    },
  ```
- It also allows to set up sequences to handle multipart queries - like atomic transactions from the Drafts example. Sequences define the order of query execution for simple queries which queryTool knows how to handle.
  ```json
  "querySequences": {
    "atomicMoveToDrafts": {
      "transaction": true,
      "steps": [
        { "queryKey": "saveBeforeMoving", "params": ["content", "id"] },
        { "queryKey": "moveToDrafts", "params": ["id"] }
      ]
    },
    "atomicMoveToPublished": {
      "transaction": true,
      "steps": [
        { "queryKey": "saveBeforeMoving", "params": ["content", "id"] },
        { "queryKey": "moveToPublished", "params": ["id"] }
      ]
    },
    "atomicMoveLatestToEditDraft": {
      "transaction": true,
      "steps": [
        { "queryKey": "moveLatestPostToEditDraft", "params": [] }
      ]
    }
  }
  ```
- The queries are "stringified" to have a more robust JSON setup - idention removed for a robust string. Easiest way to study these examples is to normalize them into a proper SQL structure with indention, and then use any AI helper to explain what the SQL query does, if not a fan of SQL. Easiest way to find usage is to take the query name and ctrl+F it in example/backend/lib/serverRouter.js.
- Can think of it the same way as Go templating - a backend-inclined person's idea of web application building. This is data-inclined persons donk-idea of web-application building in a way that need to write very little procedural code, but have to break down any feature into its representation of db state and schemas and tables.
- Following the examples should give a good overview. Especially the Drafts example.
- For example button state is defined by the query above ("fetchButtonStates"). And if frontend would be bypassed, by deleting disabled state for a button in devTools to byass db-driven button state which would allow to trigger the API endpoints bound to buttons, then it would ett the same check in backend in serverRouter - node getting pointers from DB via the query and checking if DB acually allows this action in atm - sort of like teleporting DB state validation to frotend and having it also as a stopgap in backend before any action request hits the DB - while controlled by DB:
  ```json
  "validateActionAllowed": {
      "query": "SELECT CASE WHEN $1 = 'createPost' AND (SELECT COUNT(*) FROM edit_draft) = 0 THEN true WHEN $1 = 'moveToDrafts' AND (SELECT COUNT(*) FROM edit_draft) = 1 THEN true WHEN $1 = 'moveToPublished' AND (SELECT COUNT(*) FROM edit_draft) = 1 THEN true WHEN $1 = 'editLatestPost' AND (SELECT COUNT(*) FROM edit_draft) = 0 AND ((SELECT COUNT(*) FROM draft_storage) > 0 OR (SELECT COUNT(*) FROM published_posts) > 0) THEN true WHEN $1 = 'deleteAllPosts' AND (SELECT COUNT(*) FROM draft_storage) + (SELECT COUNT(*) FROM edit_draft) + (SELECT COUNT(*) FROM published_posts) > 0 THEN true ELSE false END AS allowed;"
    },
  ``` 
  ```js
  // in serverRouter extracting db-enforced validation "checksums" from API endpoints, so validation works as an universal nested helper together with this helper
  async function validateAction(req) {
  
    // extracts the last part of the API endpoint like "moveToPublished" etc
    const actionType = req.path.split('/').pop();

    const validationQuery = queryTemplates.queries.validateActionAllowed.query;
    const result = await executeQuery(validationQuery, [actionType]);

    return result.length > 0 && result[0].allowed === true;
  
  }
  ```

### Frontend:

#### example/frontend/lib/clientApp.js

- clientApp covers the frotnend part of school reqs.
- while the essence of our framework is to turn procedural code into a language-agnostic wrapper, where could execute DB processes and queries and rebuild with whatever language, the clientApp handles the JS frontend part for the SPA experience
- It uses an unoptimized code in the sense, that IR Lwoudl likley structure it better, but school reqs pretty much enforced to write very raw vanilla JS, even if would do it better with with built in funcs and listeners etc.
- clientapp also build the frontend part of dynamic nav and footer.
- it also handles dynamic urls, exmaple-specific updates (like actual DB table counts for Drafts example for DB state), and route errors etc - again not the focus here, so basic.
  ```js
  // handle route changes - needs to be async here to use partials via the async func in index.js
  async function handleRoute(path) {

      const component = routes[path] || notFoundComponent;

      const appDiv = document.getElementById('app');
      appDiv.innerHTML = ''; 
      const content = await component();
      appDiv.appendChild(content);

      // if drafts example, then refresh db table row counts for post data
      if (path === "/drafts") {

          window.updateTableCounts();

      }

  }

  // specific link handler - also needs to be async, as otherwise will return a promise [object Promise]
  async function navigateTo(path) {

      history.pushState({}, '', path); // SPA-like change to the browser URL w/o reloading
      await handleRoute(path); // render the page after stuff is loaded

  }

  // fallback
  function notFoundComponent() {
      
      const div = document.createElement('div');
      div.innerHTML = `<h2>404 Not Found</h2>`;
      return div;

  }
  ```
- clientApp is needed more when you wnat to change the structur of the page. index.js on the other hand is to control the frontend triggers which let the DB know that it can start controlling and thinking.
- If you follow the essense and execution of the example project, then the previous point should make sense and make it easier to extrapolate any needed changes.

#### example/frontend/lib/eventSystem.js

- would not have used it at all, but mianly due to school task enforcing manual JS build for everything "frameworky", using window funcs for globally available parts for vanilla JS.
- should have some benefits tho:
- Event delegation without needing ES modules.
- did set up fallbacks in clientApp tho:
  ```js
  // enforcing global objects to exists 
  window.eventHandlers = window.eventHandlers || {};
  window.registerEvent = window.registerEvent || function () {}; // fallback if eventSystem.js fails
  window.updateTableCounts = window.updateTableCounts || function () {}; // fallback if updateTableCounts.js fails
  ```

#### example/frontend/lib/stateAndPermissions.js

- makes updating button states globally avaliable with a window func.
- could be expanded, but pretty much an helper to use button state globally.

#### example/frontend/lib/updateTableCounts.js

- This is a pure helper for the Draft example - to actually use the DB table counts - because draft and publish feature is defined by pure DB state - a post instance moves around, depending on what the DB state and actions are.

#### example/frontend/index.js

- index.js in this scope is just an example frontent facilitator, using common std patterns but in a way lighter way - just triggers frontend actions via API endpoints and listens to what DB has to say via backend.
- this is somewhat like in django - you get a rough structure ("batteries included approach) and while django views are an integral part of the framework, you need to define your own views - as it is a framework with some structure but not a library of prebuilt components.

## General recap:

- The best way to understand what is going on here likely is not via reading a wall of text of documentation, but to set up the examples with example data, and then follow the code structure, so see how it works.
- Main point is not doing a library of components, but a mini-framework which is DB driven and procedural-language agnostic - DB and data are the most valuable parts, so anything aorund the DB state and queries can be rebuilt in any other language in some way, but logic would remain the same.
- data-inclined people can build a web app via focusing on data and writing as little procedural code as possible.
- forces strng IoC
- covers all school reqs, but in a light and DB-first way.
- trying to mimic django-like full framework example mini-experience, where structure is given, but framework does not behave like a library - user can choose what and how and for what they use -> not a lego, but some tools and a framework of oppinionated ideas - merit of it is questiionable, as just reinventing a wheel here inside the school constraints. 
