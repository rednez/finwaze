import { ImageLoaderConfig } from '@angular/common';

export function appImageLoader({ src, width }: ImageLoaderConfig): string {
  if (!width) {
    return src;
  }

  const dotIndex = src.lastIndexOf('.');
  return `${src.slice(0, dotIndex)}-${width}w${src.slice(dotIndex)}`;
}
