using Microsoft.EntityFrameworkCore;
using Scalar.AspNetCore;
using WorldCupStats.Api.Data;
using WorldCupStats.Api.Services;

var builder = WebApplication.CreateBuilder(args);

// ── Port ──────────────────────────────────────────────────────────────────────
var port = Environment.GetEnvironmentVariable("PORT") ?? "5050";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

// ── Services ──────────────────────────────────────────────────────────────────
builder.Services.AddControllers()
    .AddJsonOptions(opts =>
    {
        opts.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    });

builder.Services.AddOpenApi();

builder.Services.AddDbContext<AppDbContext>(opts =>
    opts.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=worldcup.db"));

builder.Services.AddScoped<IMatchService, MatchService>();
builder.Services.AddScoped<IGroupTableService, GroupTableService>();
builder.Services.AddScoped<ITeamStatsService, TeamStatsService>();
builder.Services.AddScoped<ITournamentSummaryService, TournamentSummaryService>();
builder.Services.AddScoped<IWallChartService, WallChartService>();

// ── CORS ──────────────────────────────────────────────────────────────────────
builder.Services.AddCors(opts =>
{
    opts.AddPolicy("LocalDev", p => p
        .WithOrigins(
            "http://localhost:3000",
            "http://localhost:5000",
            "http://localhost:5050",
            "http://localhost:8080")
        .AllowAnyMethod()
        .AllowAnyHeader());

    opts.AddPolicy("Production", p => p
        .WithOrigins("https://hannahgunn97.github.io")
        .AllowAnyMethod()
        .AllowAnyHeader());
});

var app = builder.Build();

// ── CORS middleware ───────────────────────────────────────────────────────────
var corsPolicy = app.Environment.IsProduction() ? "Production" : "LocalDev";
app.UseCors(corsPolicy);

// ── Cache headers ─────────────────────────────────────────────────────────────
app.Use(async (context, next) =>
{
    context.Response.Headers["Cache-Control"] = "no-store, no-cache, must-revalidate";
    context.Response.Headers["Pragma"] = "no-cache";
    await next();
});

// ── Health check ──────────────────────────────────────────────────────────────
app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

// ── API docs ──────────────────────────────────────────────────────────────────
app.MapOpenApi();
app.MapScalarApiReference(opts => opts.Title = "World Cup Stats Hub API");

// ── Controllers ───────────────────────────────────────────────────────────────
app.MapControllers();

// ── Seed ──────────────────────────────────────────────────────────────────────
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var env = scope.ServiceProvider.GetRequiredService<IWebHostEnvironment>();
    await SeedDataLoader.SeedAsync(db, env);
}

app.Run();

public partial class Program { }
