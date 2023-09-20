const express = require("express");
const mysql = require("mysql");
const app = express();

const cors = require("cors"); // Import the cors package


app.use(cors()); // Use cors middleware to enable CORS

const port = 5000;



// MySQL Connection
const connection = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "RahulSQL2002",//my database password
  database: "blockchaindemo",
  insecureAuth: true,
});

connection.connect(function(err) {
    if (err) throw err;
    console.log("Connected!");
  });

app.use(express.json());

app.get("/api/getExpenses", (req, res) => {
    const query = "SELECT * FROM assetDetails";
    connection.query(query, (error, results) => {
      if (error) throw error;
      // console.log(results);
      res.json(results);
    });
  });

  app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
  });