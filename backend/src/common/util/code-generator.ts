import { EntityManager } from 'typeorm';

/** Business code generator, e.g. PR-261108-0003 (unique per prefix and day). */
export async function nextCode(m: EntityManager, prefix: string, table: string, column: string): Promise<string> {
  const now = new Date();
  const ymd = `${String(now.getFullYear()).slice(2)}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}`;
  const like = `${prefix}-${ymd}-%`;
  const [{ max }] = await m.query(
    `SELECT COALESCE(MAX(CAST(SPLIT_PART(${column}, '-', 3) AS INT)), 0) AS max FROM ${table} WHERE ${column} LIKE $1`,
    [like],
  );
  return `${prefix}-${ymd}-${String(Number(max) + 1).padStart(4, '0')}`;
}
