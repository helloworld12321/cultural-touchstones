/**
 * This script initializes MariaDB for testing purposes.
 *
 * It serves mostly the same role as `startup.sql`, but it uses a different
 * database name and it creates a special testing user.
 */

-- We'll use the `testing` database for our tests.
CREATE OR REPLACE DATABASE testing;
USE testing;

-- Use the same table structure as the production database.
CREATE TABLE watchlist_items (
  position INT NOT NULL PRIMARY KEY,
  contents VARCHAR(300) NOT NULL
);

-- Create a user for the tests to use.
CREATE OR REPLACE USER 'test_user'@'localhost'
  IDENTIFIED BY 'testpasswordnotactuallyasecret';

GRANT SELECT, INSERT, UPDATE, DELETE, DROP
  ON testing.*
  TO 'test_user'@'localhost';
