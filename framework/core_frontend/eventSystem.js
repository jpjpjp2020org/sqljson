/*
Manage event delegation
Avoiding needing ES modules and imports
*/

window.eventHandlers = window.eventHandlers || {};

window.registerEvent = function (eventType, selector, callback) {

    if (!window.eventHandlers[eventType]) {

        window.eventHandlers[eventType] = [];
        document.body.addEventListener(eventType, (event) => {

            window.eventHandlers[eventType].forEach(({ selector, callback }) => {
                if (event.target.matches(selector)) {
                    callback(event);
                }
            });

        });
        
    }

    window.eventHandlers[eventType].push({ selector, callback });

};
