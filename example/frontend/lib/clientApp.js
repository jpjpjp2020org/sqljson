/*
clientApp handles the frontendy part:
including nav builder, which uses routesConfig and needs only calling the func in frontend.
*/

// enforcing global objects to exists 
window.eventHandlers = window.eventHandlers || {};
window.registerEvent = window.registerEvent || function () {}; // fallback if eventSystem.js fails
window.updateTableCounts = window.updateTableCounts || function () {}; // fallback if updateTableCounts.js fails

const routes = {};

// route and also the component - as doing basic page building for a SPA-like render
window.defineRoute = function (path, componentFn) {

    routes[path] = componentFn;

};

// public app init
window.initClientApp = async function () {

    const response = await fetch('/nav-routes');
    const navData = await response.json();

    buildNavBar(navData);
    buildFooter(navData); // footer dynamic component too

    handleRoute(window.location.pathname);

}

// build <nav> from navData
function buildNavBar(navData) {

    const nav = document.createElement('nav');

    navData.forEach(({ path, label }) => {
        const link = document.createElement('a');
        link.href = path;
        link.dataset.link = 'true';  // triggers routing
        link.textContent = label || path;
        
        // manual onclick logic as per task requirements

        link.onclick = (e) => {
            e.preventDefault(); // battle with the browser
            navigateTo(path); // updating the route manually
        };

        nav.appendChild(link);
        nav.appendChild(document.createTextNode(' | '));

    });

    // Docs link to example page
    const docsLink = document.createElement('a');
    docsLink.href = "https://github.com/jpjpjp2020org";
    docsLink.textContent = "Docs";
    docsLink.target = "_blank";  // open in new tab which makes sense here as meant to accompany
    docsLink.rel = "noopener noreferrer";

    nav.appendChild(docsLink);

    document.body.prepend(nav);

}

// dynamic footer component
function buildFooter(navData) {

    const footer = document.createElement('footer');
    footer.classList.add('footer-container');

    // row 1 for std links mirroring nav
    const navLinksContainer = document.createElement('div');
    navLinksContainer.classList.add('footer-nav-links');

    navData.forEach(({ path, label }) => {
        const link = document.createElement('a');
        link.href = path;
        link.dataset.link = 'true';
        link.textContent = label || path;
        link.onclick = (e) => {
            e.preventDefault();
            navigateTo(path);
        };
        navLinksContainer.appendChild(link);
    });

    // Docs link to example page
    const docsLink = document.createElement('a');
    docsLink.href = "https://github.com/jpjpjp2020org";
    docsLink.textContent = "Docs";
    docsLink.target = "_blank";  // open in new tab which makes sense here as meant to accompany
    docsLink.rel = "noopener noreferrer";

    navLinksContainer.appendChild(docsLink);

    // row 2 currently for random external API http res (ISS location) example
    const issContainer = document.createElement('div');
    issContainer.classList.add('footer-iss-container');

    const fetchISSButton = document.createElement('button');
    fetchISSButton.textContent = "Get ISS Location (external API)";
    fetchISSButton.classList.add("fetch-iss-btn");

    const issDataDisplay = document.createElement('pre'); // mono font for raw JSON
    issDataDisplay.classList.add("iss-data");
    issDataDisplay.textContent = "External API response (if times out, try again)";

    fetchISSButton.onclick = async () => { // hitting the backend route to use the helper for ex. data example

        try {
            const response = await fetch("/api/external/iss"); // Calls backend route
            if (!response.ok) throw new Error(`HTTP error! Status: ${response.status}`);
            
            const result = await response.json();
            issDataDisplay.textContent = JSON.stringify(result, null, 2);
        } catch (error) {
            console.error("Error fetching ISS location:", error);
            issDataDisplay.textContent = "Failed to fetch ISS location.";
        }

    };

    issContainer.appendChild(fetchISSButton);
    issContainer.appendChild(issDataDisplay);

    footer.appendChild(navLinksContainer);
    footer.appendChild(issContainer);

    document.body.appendChild(footer);

}


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