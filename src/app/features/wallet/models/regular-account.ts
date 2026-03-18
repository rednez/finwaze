export interface RegularAccount {
  id: number;
  name: string;
  currency: { id: number; code: string };
  balance: number;
  canDelete: boolean;
}
