/*
Just a tracker to validate a post moving between tables with atomic transactions.
Attatching it to window and and adding scripts to index.html directly as content is dynamic anyway.
*/

window.updateTableCounts = async function () {

    try {

        const response = await fetch("/api/drafts/state");
        if (!response.ok) throw new Error(`Failed to fetch counts - Status: ${response.status}`);

        const state = await response.json();

        document.getElementById("draft_storage").textContent = state.draft_storage || "Error";
        document.getElementById("edit_draft").textContent = state.edit_draft || "Error";
        document.getElementById("published_posts").textContent = state.published_posts || "Error";

    } catch (error) {

        console.error("Error fetching table counts:", error);

    }

};
