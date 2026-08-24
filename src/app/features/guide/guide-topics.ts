import { GuideTopicConfig } from './models';

/** One guide per app section. The `key` matches the section's route segment,
 *  so the "?" help icon next to a section title can link to `/guide/<key>`.
 *  Ordering drives the hub cards and prev/next article navigation.
 *  The `key` also names the Cloudinary asset — `finwaze/guide/<key>-light`
 *  and `finwaze/guide/<key>-dark` must both exist. */
export const GUIDE_TOPICS: GuideTopicConfig[] = [
  {
    key: 'dashboard',
    image: { width: 1866, height: 1208 },
    icon: 'pi pi-th-large',
    iconClass: 'text-indigo-500 bg-indigo-500/12',
    accentClass: 'text-indigo-500',
  },
  {
    key: 'transactions',
    image: { width: 1866, height: 1099 },
    icon: 'pi pi-money-bill',
    iconClass: 'text-emerald-500 bg-emerald-500/12',
    accentClass: 'text-emerald-500',
  },
  {
    key: 'categories',
    image: { width: 1866, height: 934 },
    icon: 'pi pi-tags',
    iconClass: 'text-amber-500 bg-amber-500/12',
    accentClass: 'text-amber-500',
  },
  {
    key: 'wallet',
    image: { width: 1866, height: 1114 },
    icon: 'pi pi-wallet',
    iconClass: 'text-violet-500 bg-violet-500/12',
    accentClass: 'text-violet-500',
  },
  {
    key: 'budget',
    image: { width: 1866, height: 1189 },
    icon: 'pi pi-chart-pie',
    iconClass: 'text-sky-500 bg-sky-500/12',
    accentClass: 'text-sky-500',
  },
  {
    key: 'goals',
    image: { width: 1866, height: 1016 },
    icon: 'pi pi-flag',
    iconClass: 'text-rose-500 bg-rose-500/12',
    accentClass: 'text-rose-500',
  },
  {
    key: 'analytics',
    image: { width: 1866, height: 1254 },
    icon: 'pi pi-chart-bar',
    iconClass: 'text-fuchsia-500 bg-fuchsia-500/12',
    accentClass: 'text-fuchsia-500',
  },
];
