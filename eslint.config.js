import js from '@eslint/js';
import yml from 'eslint-plugin-yml';
import markdownPlugin from 'eslint-plugin-markdown';

export default [
  js.configs.recommended,
  ...yml.configs['flat/recommended'],
  
  // YAML configuration
  {
    files: ['**/*.yml', '**/*.yaml'],
    languageOptions: {
      parser: yml.parser,
      parserOptions: {
        defaultYAMLVersion: '1.2',
      },
    },
    rules: {
      // YAML-specific rules for GitHub Actions workflows
      'yml/quotes': ['error', { prefer: 'double', avoidEscape: false }],
      'yml/indent': ['error', 2, { indentBlockSequences: true }],
      'yml/block-mapping-colon-indicator-newline': ['error', 'never'],
      'yml/block-mapping-question-indicator-newline': ['error', 'never'],
      'yml/block-sequence-hyphen-indicator-newline': ['error', 'never'],
      'yml/flow-mapping-curly-newline': ['error', { multiline: true }],
      'yml/flow-mapping-curly-spacing': ['error', 'never'],
      'yml/flow-sequence-bracket-newline': ['error', { multiline: true }],
      'yml/flow-sequence-bracket-spacing': ['error', 'never'],
      'yml/key-spacing': ['error', { beforeColon: false, afterColon: true }],
      'yml/no-empty-document': 'error',
      'yml/no-empty-key': 'error',
      'yml/no-empty-mapping-value': 'off',
      'yml/no-empty-sequence-entry': 'error',
      'yml/no-irregular-whitespace': 'error',
      'yml/no-tab-indent': 'error',
      'yml/no-multiple-empty-lines': ['error', { max: 2, maxEOF: 1, maxBOF: 0 }],
      'yml/no-trailing-zeros': 'error',
      'yml/require-string-key': 'error',
      'yml/spaced-comment': ['error', 'always'],
      
      // GitHub Actions specific preferences
      'yml/sort-keys': 'off', // Don't enforce key sorting for GitHub Actions
      'yml/sort-sequence-values': 'off', // Don't enforce sequence sorting
      
      // Allow common GitHub Actions patterns
      'yml/plain-scalar': 'off', // Allow unquoted scalars like branch names
    },
  },
  
  // GitHub Actions specific rules
  {
    files: ['.github/workflows/*.yml', '.github/workflows/*.yaml'],
    rules: {
      // Specific rules for GitHub Actions workflow files
      'yml/quotes': ['error', { prefer: 'double', avoidEscape: true }],
      'yml/key-name-casing': 'off', // GitHub Actions uses various casings
      'yml/require-string-key': 'error',
    },
  },
  
  // GitHub Issue Template specific rules
  {
    files: ['.github/ISSUE_TEMPLATE/*.yml', '.github/ISSUE_TEMPLATE/*.yaml'],
    rules: {
      // Specific rules for GitHub Issue Template files
      'yml/quotes': ['error', { prefer: 'double', avoidEscape: true }],
      'yml/key-name-casing': 'off', // Issue templates use various casings
      'yml/require-string-key': 'error',
      'no-trailing-spaces': 'error', // Prevent trailing whitespaces
      'yml/no-multiple-empty-lines': ['error', { max: 1, maxEOF: 0, maxBOF: 0 }],
      'yml/no-irregular-whitespace': 'error', // Prevent irregular whitespace characters
    },
  },
  
  // Markdown configuration
  {
    files: ['**/*.md'],
    plugins: {
      markdown: markdownPlugin,
    },
    processor: 'markdown/markdown',
    rules: {
      // Disable some JS rules that don't make sense for markdown
      'no-undef': 'off',
      'no-unused-vars': 'off',
      'no-console': 'off',
      'no-irregular-whitespace': 'off',
    },
  },
  
  // JavaScript/TypeScript code blocks in Markdown
  {
    files: ['**/*.md/*.js', '**/*.md/*.ts', '**/*.md/*.jsx', '**/*.md/*.tsx'],
    rules: {
      // Rules for code blocks in markdown
      'no-undef': 'off',
      'no-unused-vars': 'off',
      'no-console': 'off',
      'no-irregular-whitespace': 'off',
    },
  },
];
