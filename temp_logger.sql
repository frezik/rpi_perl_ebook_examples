CREATE TABLE temperature (
    id INTEGER PRIMARY KEY,
    temperature INTEGER NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
