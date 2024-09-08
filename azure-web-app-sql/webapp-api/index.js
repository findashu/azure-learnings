import express from 'express';
import mssql from 'mssql';

const app = express();
const port = process.env.PORT || 3000

// connection using managed identity
const config = {
    server: 'skillhub-sql-dev.database.windows.net',
    port: 1433,
    database: 'skillhubdb',
    authentication: {
        type: 'azure-active-directory-msi-app-service'
    },
    options: {
        encrypt: true
    }
}

async function connectAndQuery() {
    try {
        // if using connection string pass - process.env.SQLCONNSTR_Database
        const connection = await mssql.connect(config);

        console.log("Reading rows from the Table...");
        const result = await connection.request().query(`select * from Employees`);

        console.log(result.recordset);
        return result.recordset
    } catch (err) {
        console.error(err.message);
    }
}

app.get('/', async (req, res) => {
    let result = await connectAndQuery()
    res.status(200).json({result});
})


app.listen(port, () => {
    console.log(`listening on port ${port}`)
})