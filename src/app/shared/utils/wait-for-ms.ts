export const waitFormMs = async (ms = 200) =>
  new Promise((resolve) => setTimeout(resolve, ms));
