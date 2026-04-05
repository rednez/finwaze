export function toNameOptions(strings: string[]): { name: string }[] {
  return strings.map((c) => ({ name: c }));
}
