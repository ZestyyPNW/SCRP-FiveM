-- ND Inventory Database Setup
-- This adds an inventory column to your existing characters table

-- Check if the inventory column exists, if not add it
ALTER TABLE `characters`
ADD COLUMN IF NOT EXISTS `inventory` LONGTEXT DEFAULT NULL;

-- Optional: If you want to reset all inventories to empty (careful with this!)
-- UPDATE `characters` SET `inventory` = NULL;
