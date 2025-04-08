/*

add a generic example later after abstracting the essence of this speific db-based example

This is the file which enforced PoC later. When initial dev IRL would match the raw queries and the process, then the maintainer can operate on the ocnfig file alone, not touching raw queries etc.

*/

const inputConfig = {
    
    // Limit example
    "fetchMoviesByRange": {
        
        required: ["minRating", "maxRating", "sortOrder", "limit"],
        defaults: { minRating: 0, maxRating: 5, sortOrder: "DESC", limit: 10 },
        validate: (params) => {
            const minRating = parseFloat(params.minRating);
            const maxRating = parseFloat(params.maxRating);
            const limit = parseInt(params.limit, 10);
            const validSort = ["ASC", "DESC"].includes(params.sortOrder.toUpperCase());

            if (isNaN(minRating) || minRating < 0 || minRating > 5) {
                throw new Error("Invalid min rating. Must be between 0 and 5.");
            }
            if (isNaN(maxRating) || maxRating < 0 || maxRating > 5 || maxRating < minRating) {
                throw new Error("Invalid max rating. Must be between 0 and 5 and higher than min.");
            }
            if (isNaN(limit) || limit <= 0) {
                throw new Error("Limit must be a positive number.");
            }
            if (!validSort) {
                throw new Error("Sort order must be 'ASC' or 'DESC'.");
            }

            return { minRating, maxRating, sortOrder: params.sortOrder.toUpperCase(), limit };
        }

    },

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

};

module.exports = inputConfig;