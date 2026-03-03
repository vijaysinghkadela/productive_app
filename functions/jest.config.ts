import type { Config } from 'jest';

const config: Config = {
  roots: ['<rootDir>/tests'],
  testMatch: ['**/*.test.ts'],
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
  moduleFileExtensions: ['ts', 'js', 'json'],
  moduleNameMapper: {
    '^@shared/(.*)$': '<rootDir>/src/shared/$1',
    '^@auth/(.*)$': '<rootDir>/src/auth/$1',
    '^@sessions/(.*)$': '<rootDir>/src/sessions/$1',
    '^@usage/(.*)$': '<rootDir>/src/usage/$1',
    '^@goals/(.*)$': '<rootDir>/src/goals/$1',
    '^@habits/(.*)$': '<rootDir>/src/habits/$1',
    '^@achievements/(.*)$': '<rootDir>/src/achievements/$1',
    '^@ai/(.*)$': '<rootDir>/src/ai/$1',
  },
  testEnvironment: 'node',
  collectCoverageFrom: ['src/**/*.ts', '!src/index.ts'],
  coverageThreshold: {
    global: { branches: 60, functions: 60, lines: 70, statements: 70 },
  },
  verbose: true,
};

export default config;
