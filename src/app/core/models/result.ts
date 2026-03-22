export interface ResultOk {
  ok: true;
  error: null;
}
export interface ResultError<E = Error> {
  error: E;
  ok: false;
}

export type Result<E = Error> = ResultOk | ResultError<E>;
