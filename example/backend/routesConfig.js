/*

All paths should be configured here for this example framework usage - sort of like how django uses urls.py

*/

const path = require('path');

// routesConfig also powers the nav builder logic for frontend - make sure to include the  inNav, and label when inNav is true

// SPA-like setup on 1 html - can point to other templates too.
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
        path: '/limit',
        inNav: true, // show in nav
        label: 'Limit',
        handler: (req, res) => {
            // Serve the index page
            res.sendFile(path.join(__dirname, '../frontend/index.html'));
        }
    },
    {
        method: 'GET',
        path: '/drafts',
        inNav: true, // show in nav
        label: 'Drafts',
        handler: (req, res) => {
            // Serve the index page
            res.sendFile(path.join(__dirname, '../frontend/index.html'));
        }
    },
    {
        method: 'GET',
        path: '/access',
        inNav: true, // show in nav
        label: 'Access',
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
  