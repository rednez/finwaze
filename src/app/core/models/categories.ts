export interface Group {
  id: number;
  name: string;
}

export interface Category {
  id: number;
  name: string;
  groupId: number;
  groupName: string;
}
