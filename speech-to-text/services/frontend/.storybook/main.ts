import type { StorybookConfig } from '@storybook/nextjs'

const config: StorybookConfig = {
  stories: ['../stories/**/*.stories.@(js|jsx|mjs|ts|tsx)'],
  addons: [
    '@storybook/addon-links',
    '@storybook/addon-essentials',
    '@storybook/addon-onboarding',
    '@storybook/addon-interactions',
  ],
  framework: {
    name: '@storybook/nextjs',
    options: {},
  },
  docs: {
    autodocs: 'tag',
  },
  staticDirs: ['../public'],
  typescript: {
    check: false,
    reactDocgen: 'react-docgen-typescript',
    reactDocgenTypescriptOptions: {
      shouldExtractLiteralValuesFromEnum: true,
      propFilter: (prop) => (prop.parent ? !/node_modules/.test(prop.parent.fileName) : true),
    },
  },
  webpackFinal: async (config) => {
    // Ensure Tailwind CSS is processed
    config.module = config.module || {}
    config.module.rules = config.module.rules || []
    
    // Find and modify the CSS rule
    const cssRule = config.module.rules.find(
      (rule) => rule && typeof rule === 'object' && rule.test && rule.test.toString().includes('css')
    )
    
    if (cssRule && typeof cssRule === 'object' && Array.isArray(cssRule.use)) {
      const postCssLoader = cssRule.use.find(
        (use) => use && typeof use === 'object' && use.loader && use.loader.includes('postcss-loader')
      )
      
      if (postCssLoader && typeof postCssLoader === 'object') {
        postCssLoader.options = {
          ...postCssLoader.options,
          postcssOptions: {
            plugins: [
              require('tailwindcss'),
              require('autoprefixer'),
            ],
          },
        }
      }
    }
    
    return config
  },
}

export default config