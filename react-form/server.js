const express = require('express');
const axios = require('axios');
const path = require('path');
const bodyParser = require('body-parser');
const app = express();
app.use(express.json());

const port = 8080;
const daprPort = process.env.DAPR_HTTP_PORT ?? 3500;
const pubsubName = 'pubsub';
const daprUrl = `http://localhost:${daprPort}/v1.0`;
const serviceName = 'csharp-service';

// Publish to topic (messageType) using Dapr Pub/Sub API
app.post('/publish', async (req, res) => {
  console.log("Endpoint: ");
  console.log(`http://localhost:${daprPort}/v1.0/publish/${pubsubName}/${req.body?.messageType}`);
  console.log("Publishing: ", req.body);
  await axios.post(`http://localhost:${daprPort}/v1.0/publish/${pubsubName}/${req.body?.messageType}`, req.body);
  return res.sendStatus(200);
});

// Invoke method using Dapr service-to-service invocation API
app.post('/invoke', async (req, res) => {
  console.log("Endpoint: ");
  console.log(`${daprUrl}/invoke/${serviceName}/method/${req.body?.messageType}`);
  console.log("Invoking: ", req.body);
  await axios.post(`${daprUrl}/invoke/${serviceName}/method/${req.body?.messageType}`, req.body);
  return res.sendStatus(200);
});

// Serve static files
app.use(express.static(path.join(__dirname, 'client/build')));

// Map default route to React client
app.get('/', async function (_req, res) {
  await res.sendFile(path.join(__dirname, 'client/build', 'index.html'));
});

app.listen(process.env.PORT || port, () => console.log(`Listening on port ${port}!`));
