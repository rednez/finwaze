import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { RatingModule } from 'primeng/rating';
import { RippleModule } from 'primeng/ripple';
import {
  TableEditCompleteEvent,
  TableModule,
  TableRowCollapseEvent,
  TableRowExpandEvent,
} from 'primeng/table';
import { TagModule } from 'primeng/tag';
import { ToastModule } from 'primeng/toast';
import { ProductService } from './products.service';

@Component({
  imports: [
    CommonModule,
    ButtonModule,
    RatingModule,
    TableModule,
    TagModule,
    ToastModule,
    RippleModule,
    FormsModule,
  ],
  templateUrl: './create-budget.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [ProductService],
})
export class CreateBudget implements OnInit {
  // TODO: temp
  private productService = inject(ProductService);

  products = signal<{ id: string }[]>([]);
  expandedRows: Record<string, boolean> = {};

  ngOnInit(): void {
    this.productService.getProductsWithOrdersSmall().then((data) => {
      this.products.set(data);
    });
  }

  expandAll() {
    this.expandedRows = this.products().reduce<Record<string, boolean>>(
      (acc, p) => ({ ...acc, [p.id]: true }),
      {},
    );
  }

  collapseAll() {
    this.expandedRows = {};
  }

  getSeverity(status: string) {
    switch (status) {
      case 'INSTOCK':
        return 'success';
      case 'LOWSTOCK':
        return 'warn';
      case 'OUTOFSTOCK':
      default:
        return 'danger';
    }
  }

  getStatusSeverity(status: string) {
    switch (status) {
      case 'PENDING':
        return 'warn';
      case 'DELIVERED':
        return 'success';
      case 'CANCELLED':
      default:
        return 'danger';
    }
  }

  onEditComplete($event: TableEditCompleteEvent) {
    console.log('Edit Complete Event:', $event);
  }

  onRowExpand(event: TableRowExpandEvent) {
    // TODO
    console.log(event);

    // this.messageService.add({
    //   severity: 'info',
    //   summary: 'Product Expanded',
    //   detail: event.data.name,
    //   life: 3000,
    // });
  }

  onRowCollapse(event: TableRowCollapseEvent) {
    // TODO
    console.log(event);

    // this.messageService.add({
    //   severity: 'success',
    //   summary: 'Product Collapsed',
    //   detail: event.data.name,
    //   life: 3000,
    // });
  }
}
