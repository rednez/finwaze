export const generateAnalogColors = (count: number) => {
  const documentStyle = getComputedStyle(document.documentElement);

  const colorsData = [
    { name: 'primary', tones: [500, 400, 300, 200] },
    { name: 'purple', tones: [500, 400, 300, 200] },
    { name: 'gray', tones: [500, 400, 300, 200] },
  ];

  const colorsList = colorsData
    .map((color) =>
      color.tones.map((tone) =>
        documentStyle.getPropertyValue(`--p-${color.name}-${tone}`),
      ),
    )
    .reduce((prev, curr) => [...prev, ...curr], []);

  if (count < colorsList.length) {
    return colorsList.slice(0, count);
  } else if (count === colorsList.length) {
    return colorsList;
  } else {
    const lastColorIndex = colorsList.length - 1;
    let currentColorIndex = 0;

    return Array.from({ length: count }, (_, index) => {
      if (currentColorIndex <= lastColorIndex) {
        return colorsList[currentColorIndex++];
      } else {
        currentColorIndex = 1;
        return colorsList[0];
      }
    });
  }
};
