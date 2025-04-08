const express = require('express');
const { initServerRoutes } = require('./lib/serverRouter');
const routesConfig = require('./routesConfig');

const app = express();

// framework will be called with the config which defines actul paths
initServerRoutes(app, routesConfig);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server on port ${PORT}`));

/*

server router in the framework should handle most and paths would be defined in backend/routesConfig.js

*/