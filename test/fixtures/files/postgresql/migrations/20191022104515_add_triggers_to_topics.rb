class AddTriggersToTopics < ActiveRecord::Migration[6.0]
  def change
    execute <<-SQL
      CREATE OR REPLACE FUNCTION jsonb_diff ( arg1 jsonb, arg2 jsonb ) RETURNS jsonb AS $$
        SELECT 
          COALESCE(json_object_agg(key, value), '{}')::jsonb
        FROM 
          jsonb_each(arg1)
        WHERE 
          (arg1 -> key) <> (arg2 -> key) 
          OR (arg2 -> key) IS NULL
      $$ LANGUAGE SQL;

      CREATE OR REPLACE FUNCTION notice_insert() RETURNS trigger AS $$
        DECLARE
          channel_name varchar DEFAULT (TG_TABLE_NAME || '_notices');
        BEGIN
          PERFORM pg_notify(channel_name, json_build_object('action', TG_OP, 'id', NEW.id)::text);

          RETURN NEW;
        END;
      $$ LANGUAGE plpgsql;

      CREATE OR REPLACE FUNCTION notice_update() RETURNS trigger AS $$
        DECLARE
          channel_name varchar DEFAULT (TG_TABLE_NAME || '_notices');
          js_new jsonb := row_to_json(NEW)::jsonb;
          js_old jsonb := row_to_json(OLD)::jsonb;
        BEGIN
          PERFORM pg_notify(channel_name, json_build_object('action', TG_OP, 'id', NEW.id, 'diff', jsonb_diff(js_old, js_new))::text);

          RETURN NEW;
        END;
      $$ LANGUAGE plpgsql;

      CREATE OR REPLACE FUNCTION notice_delete() RETURNS trigger as $$
        DECLARE
          channel_name varchar DEFAULT (TG_TABLE_NAME || '_notices');
        BEGIN
          PERFORM pg_notify(channel_name, json_build_object('action', TG_OP, 'diff', OLD)::text);

          RETURN OLD;
        END;
      $$ LANGUAGE plpgsql;

      -- DROP TRIGGER IF EXISTS notice_on_insert on public.events;
      CREATE TRIGGER notice_on_insert
        AFTER INSERT ON public.topics FOR EACH ROW
        EXECUTE PROCEDURE notice_insert();

      CREATE TRIGGER notice_on_update
        AFTER UPDATE ON public.topics FOR EACH ROW
        EXECUTE PROCEDURE notice_update();

      CREATE TRIGGER notice_on_delete
        AFTER DELETE ON public.topics FOR EACH ROW
        EXECUTE PROCEDURE notice_delete();
    SQL
  end
end
