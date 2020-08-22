/**
 * This script initializes MariaDB. It creates tables and things like that.
 *
 * This script is VERY DESTRUCTIVE: if there's an old database running, it will
 * be dropped, and all data will be lost. As such, this script is mostly just
 * for development.
 */

-- We'll use the `cultural_touchstones` database for everything.
CREATE OR REPLACE DATABASE cultural_touchstones
  CHARACTER SET 'utf8mb4';

USE cultural_touchstones;

/**
 * These are the movies listed in your watchlist.
 */
CREATE TABLE watchlist_items (
  -- This item's index in your watchlist (counting from zero).
  position INT NOT NULL PRIMARY KEY,

  -- The text content of the item (ie, the movie's name).
  contents VARCHAR(300) NOT NULL
);
