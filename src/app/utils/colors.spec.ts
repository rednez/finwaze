import { generateAnalogColors } from './colors';

describe('generateAnalogColors', () => {
  it('should generate the correct number of colors', () => {
    expect(generateAnalogColors(5).length).toBe(5);
    expect(generateAnalogColors(100).length).toBe(100);
  });

  it('should return colors for all requested counts', () => {
    const colors = generateAnalogColors(100);
    expect(colors[99]).toBeDefined();
  });
});
