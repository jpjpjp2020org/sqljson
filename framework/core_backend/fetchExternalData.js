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