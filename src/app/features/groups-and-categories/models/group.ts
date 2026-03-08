import { Group } from '@core/models/categories';
import { CategoryWithTxCount } from './category';

export interface GroupWithCategories extends Group {
  categories: CategoryWithTxCount[];
}
