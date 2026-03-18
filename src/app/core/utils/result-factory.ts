import { ResultError, ResultOk } from '../models/result';

export const resultOk = (): ResultOk => ({
  ok: true,
  error: null,
});

export const resultError = <E = Error>(error: E): ResultError<E> => ({
  ok: false,
  error,
});
