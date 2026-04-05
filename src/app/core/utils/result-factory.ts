import { ResultError, ResultOk } from '../models/result';

export const resultOk = (): ResultOk => ({
  ok: true,
  error: null,
});

export const resultError = (error: unknown): ResultError<Error> => ({
  ok: false,
  error: error instanceof Error ? error : new Error('Unknown error'),
});
