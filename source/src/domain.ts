import { z } from 'zod';
const personName = z.string().trim().min(3, 'Informe um nome com pelo menos 3 caracteres.').max(160);
export const responseSchema = z.object({
  name: personName,
  registration: z.string().trim().regex(/^\d{4,20}$/, 'Informe sua matrícula com 4 a 20 dígitos.'),
  municipality: z.string().trim().min(2, 'Informe o município de lotação.').max(100),
  attending: z.boolean(),
  guests: z.array(personName).max(100, 'Para mais de 100 convidados, entre em contato com a organização.'),
  version: z.number().int().nonnegative(),
}).strict().superRefine((value, ctx) => {
  if (!value.attending && value.guests.length) ctx.addIssue({code: 'custom', path: ['guests'], message: 'Uma resposta de ausência não pode conter convidados.'});
});
export type Entry = z.infer<typeof responseSchema> & { updatedAt?: string };
export type ReportEntry = Entry & { id: string; createdAt: string };
export function totals(rows: Entry[]) {
  const confirmed = rows.filter(r => r.attending);
  const guests = confirmed.reduce((n, r) => n + r.guests.length, 0);
  return { confirmed: confirmed.length, absent: rows.length - confirmed.length, guests, participants: confirmed.length + guests };
}
