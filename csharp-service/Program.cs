using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Dapr.Client;
using Dapr.Client.Autogen.Grpc.v1;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var baseURL = (Environment.GetEnvironmentVariable("BASE_URL") ?? "http://localhost") + ":" 
+ (Environment.GetEnvironmentVariable("DAPR_HTTP_PORT") ?? "3500");
const string DAPR_STATE_STORE = "statestore";

var daprClient = new DaprClientBuilder().Build();
// var httpClient = new HttpClient();
// httpClient.DefaultRequestHeaders.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));

// Route /A
app.MapPost("/A", async (ILogger<Program> logger, MessageEvent item) => {
    Console.WriteLine($"Received message on Route A: {item.Message}");

    // Saving message in state store
    var messageJson = JsonSerializer.Serialize(
        new[] {
            new {
                key = "A",
                value = item.Message
            }
        }
    );
    var state = new StringContent(messageJson, Encoding.UTF8, "application/json");
    await daprClient.SaveStateAsync(DAPR_STATE_STORE, "A", item.Message);
    //await httpClient.PostAsync($"{baseURL}/v1.0/state/{DAPR_STATE_STORE}", state);
    Console.WriteLine("Saved item in state store: " + item.Message);

    // Wait 2 seconds to cause a sluggish response for debugging purposes
    // Should make POST:/A (Dapr -> App) calls slow
    await Task.Delay(5000);
    return Results.Ok();
});

// Route /B
app.MapPost("/B", async (ILogger<Program> logger, MessageEvent item) => {
    Console.WriteLine($"Received message on Route B: {item.Message}");

    // Saving message in state store
    // var messageJson = JsonSerializer.Serialize(
    //     new[] {
    //         new {
    //             key = "B",
    //             value = item.Message
    //         }
    //     }
    // );

    var value = new MessageEvent()
    {
        MessageType = "B",
        Message = item.Message
    };
    
    //var state = new StringContent(messageJson, Encoding.UTF8, "application/json");
    //await httpClient.PostAsync($"{baseURL}/v1.0/state/{DAPR_STATE_STORE}", state);
    await daprClient.SaveStateAsync(DAPR_STATE_STORE, "local11", value);
    Console.WriteLine("Saved item in state store to key local11 with value: " + item.Message);

    // Wait 2 seconds to cause a sluggish response for debugging purposes
    // Should make POST:/B (Dapr -> App) calls slow
    // await Task.Delay(5000);

    //var order = new MessageEvent();
    MessageEvent order = null;
    order = await daprClient.GetStateAsync<MessageEvent>(DAPR_STATE_STORE, "local11");
    Console.WriteLine($"Got State: {order.Message}");

    return Results.Ok();
});

app.Run();

internal class MessageEvent{
    public string MessageType  {get; set; }
    public string Message {get; set; }
}