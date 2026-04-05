import { FakeQueryBuilder, FakeTableBuilder } from './fake-query-builder';
import { getFakeRpcData, getFakeTableData } from './demo-data';

export class DemoSupabaseClient {
  from(table: string): FakeTableBuilder {
    return new FakeTableBuilder(getFakeTableData(table));
  }

  rpc(fn: string, params?: Record<string, unknown>): FakeQueryBuilder {
    return new FakeQueryBuilder(getFakeRpcData(fn, params));
  }
}
