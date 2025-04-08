const pool = require('./pool');
const queryTemplates = require('./rawQueryTemplates.json');

// simple tool for Limit example
async function executeQuery(sql, params = []) {

    try {
        const { rows } = await pool.query(sql, params);
        return rows;
    } catch (error) {
        console.error("Query Execution Failed:", error);
        throw new Error("Database query failed");
    }

}

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

module.exports = { executeQuery, executeAtomicQuery };