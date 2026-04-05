export class FakeQueryBuilder implements PromiseLike<unknown> {
  protected _data: unknown;
  private _single = false;
  private _isCount = false;

  constructor(data: unknown) {
    this._data = data;
  }

  select(_cols?: string, opts?: { head?: boolean; count?: string }): this {
    if (opts?.count) this._isCount = true;
    return this;
  }

  eq(_col: string, _val: unknown): this {
    return this;
  }

  neq(_col: string, _val: unknown): this {
    return this;
  }

  order(_col: string, _opts?: unknown): this {
    return this;
  }

  limit(_n: number): this {
    return this;
  }

  overrideTypes(): this {
    return this;
  }

  single(): this {
    this._single = true;
    return this;
  }

  then<TResult1 = unknown, TResult2 = never>(
    onfulfilled?: ((value: unknown) => TResult1 | PromiseLike<TResult1>) | null,
    _onrejected?: ((reason: unknown) => TResult2 | PromiseLike<TResult2>) | null,
  ): PromiseLike<TResult1 | TResult2> {
    const arr = Array.isArray(this._data)
      ? this._data
      : this._data != null
        ? [this._data]
        : [];

    let result: Record<string, unknown>;

    if (this._isCount) {
      result = { data: null, count: arr.length, error: null };
    } else if (this._single) {
      result = { data: arr[0] ?? null, error: null };
    } else {
      result = { data: arr, error: null };
    }

    return Promise.resolve(result).then(onfulfilled);
  }
}

export class FakeTableBuilder extends FakeQueryBuilder {
  insert(payload: unknown): this {
    const rows = Array.isArray(payload) ? payload : [payload];
    this._data = rows.map((r, i) => ({ id: 90000 + i, ...(r as object) }));
    return this;
  }

  update(_payload: unknown): this {
    return this;
  }

  delete(): this {
    this._data = null;
    return this;
  }
}
