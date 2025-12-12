export const hash = jest.fn().mockResolvedValue('hashedPassword');
export const compare = jest.fn().mockResolvedValue(true);
export const genSalt = jest.fn().mockResolvedValue('salt');
