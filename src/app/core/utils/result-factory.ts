import { ResultError, ResultOk } from '../models/result';

// export const resultOk = <T>(data: T): ResultOk<T> => ({
//   ok: true,
//   data,
//   error: null,
// });

// export const resultError = <E = Error>(error: E): ResultError<E> => ({
//   ok: false,
//   error,
//   data: null,
// });

export const resultOk = (): ResultOk => ({
  ok: true,
  error: null,
});

export const resultError = <E = Error>(error: E): ResultError<E> => ({
  ok: false,
  error,
});
