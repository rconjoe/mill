// there are multiple modes to add as header: //nobundling //native //npm //nodejs
// https://www.windmill.dev/docs/getting_started/scripts_quickstart/typescript#modes

// import { toWords } from "number-to-words@1"
import * as wmill from "windmill-client"
import { DB } from "./types"
import { Pool } from "pg"
import { Kysely, PostgresDialect } from "kysely"
// fill the type, or use the +Resource type to get a type-safe reference to a resource
// type Postgresql = object


export async function main(
  is_active: boolean,
  product_id?: number,
  name?: string,
  // description?: string,
  // created_at?: Date
) {
  const connectionString = await wmill.getVariable('f/db/tonka_railway_pg');

  const dialect = new PostgresDialect({
    pool: new Pool({
      connectionString
    })
  });
  const db = new Kysely<DB>({ dialect });
  let query = db.selectFrom("products").where("is_active", "=", is_active);

  if (product_id) {
    query = query.where("product_id", "=", product_id);
  }

  if (name) {
    query = query.where("name", "=", name);
  }

  return await query.selectAll().execute();
}
