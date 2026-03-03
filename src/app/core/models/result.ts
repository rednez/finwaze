// export type ResultOk<T> = { data: T; ok: true; error: null };
// export type ResultError<E = Error> = { error: E; ok: false; data: null };

export type ResultOk = { ok: true; error: null };
export type ResultError<E = Error> = { error: E; ok: false };

export type Result<E = Error> = ResultOk | ResultError<E>;
