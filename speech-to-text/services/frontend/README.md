# Speech-to-Text Frontend

A modern Next.js frontend application for Dutch speech transcription using Google Cloud Speech-to-Text API. Built with React, TypeScript, Tailwind CSS, and Storybook for component development.

## Features

- 🎨 **Modern UI**: Built with Next.js 15, React 19, and Tailwind CSS
- 📱 **Responsive Design**: Works seamlessly on desktop, tablet, and mobile
- 🎯 **Drag & Drop Upload**: Intuitive file upload with progress tracking
- 📊 **Real-time Updates**: WebSocket connection for live transcription progress
- 🔄 **Audio Extraction**: Automatic audio extraction from video files
- 📝 **Rich Transcription Results**: Copy, download, and manage transcripts
- 🎭 **Component Library**: Comprehensive Storybook documentation
- ⚡ **Performance Optimized**: Built with modern web standards

## Technology Stack

- **Next.js 15** - React framework with App Router
- **React 19** - Latest React with improved performance
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first CSS framework
- **Framer Motion** - Smooth animations and transitions
- **Storybook** - Component development and documentation
- **React Dropzone** - File upload functionality
- **React Hot Toast** - Beautiful notifications
- **Axios** - HTTP client for API communication
- **Heroicons** - Beautiful SVG icons

## Prerequisites

- Node.js 18+ and npm 8+
- Backend service running (see `../backend/README.md`)
- Modern web browser with JavaScript enabled

## Local Development Setup

### 1. Install Dependencies

```bash
# Install Node.js dependencies
npm install

# Verify installation
npm list --depth=0
```

### 2. Environment Configuration

Create a `.env.local` file in the frontend directory:

```env
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_WS_URL=ws://localhost:8000

# For production deployment
# NEXT_PUBLIC_API_URL=https://speech-backend-xyz.run.app
# NEXT_PUBLIC_WS_URL=wss://speech-backend-xyz.run.app

# Environment
NODE_ENV=development
```

### 3. Start Development Server

```bash
# Start Next.js development server
npm run dev

# The application will be available at:
# http://localhost:3000
```

### 4. Start Storybook (Optional)

```bash
# Start Storybook for component development
npm run storybook

# Storybook will be available at:
# http://localhost:6006
```

## Development Workflow

### File Structure

```
src/
├── app/                    # Next.js App Router pages
│   ├── layout.tsx         # Root layout with header/footer
│   └── page.tsx           # Main upload page
├── components/            # Reusable UI components
│   ├── FileUpload.tsx     # Drag & drop file upload
│   ├── ProgressBar.tsx    # Progress tracking component
│   └── TranscriptionResult.tsx # Results display
├── hooks/                 # Custom React hooks
│   └── useTranscription.ts # Transcription state management
├── lib/                   # Utility libraries
│   └── api.ts            # API client and WebSocket
├── styles/               # Global styles and CSS
│   └── globals.css       # Tailwind and custom styles
└── types/                # TypeScript type definitions
    └── transcription.ts  # API response types
```

### Available Scripts

```bash
# Development
npm run dev              # Start development server
npm run build           # Build for production
npm run start           # Start production server
npm run lint            # Run ESLint
npm run lint:fix        # Fix ESLint issues
npm run type-check      # Run TypeScript checks

# Storybook
npm run storybook       # Start Storybook dev server
npm run build-storybook # Build Storybook for deployment

# Testing
npm run test            # Run Jest tests
npm run test:watch      # Run tests in watch mode
npm run test:coverage   # Run tests with coverage
```

### Component Development with Storybook

Storybook provides an isolated environment for developing and testing components:

1. **Start Storybook**: `npm run storybook`
2. **Browse Components**: Navigate to http://localhost:6006
3. **Interactive Testing**: Try different props and states
4. **Documentation**: View auto-generated docs for each component

Example story structure:
```typescript
// stories/ComponentName.stories.ts
import type { Meta, StoryObj } from '@storybook/react'
import ComponentName from '@/components/ComponentName'

const meta: Meta<typeof ComponentName> = {
  title: 'Components/ComponentName',
  component: ComponentName,
  // ... configuration
}

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    // ... props
  },
}
```

## API Integration

### Backend Communication

The frontend communicates with the backend through:

1. **REST API**: For file uploads and transcription management
2. **WebSocket**: For real-time progress updates

### API Client Usage

```typescript
import { ApiClient } from '@/lib/api'

// Upload file
const result = await ApiClient.uploadFile(file)

// Start transcription
const response = await ApiClient.startTranscription({
  gcs_uri: 'gs://bucket/file.mp3',
  language_code: 'nl-NL'
})

// Get status
const status = await ApiClient.getTranscriptionStatus(jobId)
```

### WebSocket Integration

```typescript
import { WebSocketClient } from '@/lib/api'

const wsClient = new WebSocketClient(
  jobId,
  (data) => console.log('Progress:', data),
  (error) => console.error('Error:', error)
)

wsClient.connect()
```

## Styling and Theming

### Tailwind CSS Configuration

The project uses a custom Tailwind configuration with:

- **Extended Color Palette**: Primary, secondary, success, warning, error colors
- **Custom Animations**: Fade-in, slide-up, pulse effects
- **Typography**: Inter font family with JetBrains Mono for code
- **Component Classes**: Pre-built button, card, and form styles

### Component Styling Patterns

```typescript
// Using clsx for conditional classes
import clsx from 'clsx'

const buttonClasses = clsx(
  'btn-primary',
  {
    'opacity-50': disabled,
    'bg-red-500': hasError
  }
)

// Using Framer Motion for animations
import { motion } from 'framer-motion'

<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.5 }}
>
  Content
</motion.div>
```

## Testing

### Unit Testing

```bash
# Run all tests
npm run test

# Run tests in watch mode
npm run test:watch

# Run with coverage
npm run test:coverage
```

### Component Testing

```typescript
// Example component test
import { render, screen } from '@testing-library/react'
import FileUpload from '@/components/FileUpload'

test('renders file upload component', () => {
  render(<FileUpload onFileSelect={jest.fn()} />)
  expect(screen.getByText('Upload audio or video file')).toBeInTheDocument()
})
```

### Integration Testing

Test the complete upload and transcription flow:

1. **File Selection**: Test drag & drop and file picker
2. **Upload Progress**: Verify progress bar updates
3. **WebSocket Connection**: Test real-time updates
4. **Result Display**: Verify transcript rendering

## Docker Local Testing

### Build Docker Image

```bash
# Build the frontend image
docker build -t speech-frontend .

# Build with build arguments
docker build \
  --build-arg NEXT_PUBLIC_API_URL=http://localhost:8000 \
  --build-arg NEXT_PUBLIC_WS_URL=ws://localhost:8000 \
  -t speech-frontend .
```

### Run Docker Container

```bash
# Run the container
docker run -p 3000:3000 speech-frontend

# Run with environment variables
docker run -p 3000:3000 \
  -e NEXT_PUBLIC_API_URL=http://localhost:8000 \
  -e NEXT_PUBLIC_WS_URL=ws://localhost:8000 \
  speech-frontend
```

### Docker Compose

Create `docker-compose.yml` for local development:

```yaml
version: '3.8'
services:
  frontend:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://backend:8000
      - NEXT_PUBLIC_WS_URL=ws://backend:8000
    depends_on:
      - backend

  backend:
    build: ../backend
    ports:
      - "8000:8000"
    # ... backend configuration
```

Run with: `docker-compose up`

## Performance Optimization

### Build Optimization

The frontend is optimized for production with:

- **Code Splitting**: Automatic route-based splitting
- **Image Optimization**: Next.js Image component
- **Bundle Analysis**: Use `npm run build` to see bundle sizes
- **Static Generation**: Pre-rendered pages where possible

### Runtime Performance

- **Lazy Loading**: Components loaded on demand
- **Memoization**: React.memo for expensive components
- **Virtual Scrolling**: For large transcript results
- **WebSocket Optimization**: Automatic reconnection and cleanup

### Monitoring Bundle Size

```bash
# Analyze bundle size
npm run build

# Use webpack-bundle-analyzer (optional)
npm install --save-dev webpack-bundle-analyzer
ANALYZE=true npm run build
```

## Deployment

### Cloud Run Deployment

The frontend is configured for automatic deployment via Cloud Build:

```bash
# Manual deployment
gcloud builds submit --config=cloudbuild.yaml

# Or deploy directly
gcloud run deploy speech-frontend \
  --source . \
  --region=europe-west1 \
  --allow-unauthenticated
```

### Environment Variables for Production

Set these in Cloud Run:

- `NEXT_PUBLIC_API_URL`: Backend service URL
- `NEXT_PUBLIC_WS_URL`: Backend WebSocket URL
- `NODE_ENV=production`

### CDN and Caching

For production deployment:

1. **Static Assets**: Served from Cloud Storage or CDN
2. **API Responses**: Cached with appropriate headers
3. **Page Caching**: Next.js ISR for static content

## Troubleshooting

### Common Issues

#### 1. Backend Connection Failed

**Problem**: Cannot connect to backend API

**Solutions:**
```bash
# Check environment variables
echo $NEXT_PUBLIC_API_URL

# Verify backend is running
curl http://localhost:8000/

# Check CORS configuration
# Ensure backend allows frontend origin
```

#### 2. WebSocket Connection Issues

**Problem**: Real-time updates not working

**Solutions:**
```bash
# Check WebSocket URL
echo $NEXT_PUBLIC_WS_URL

# Test WebSocket connection
wscat -c ws://localhost:8000/ws/test-job-id

# Check browser console for errors
```

#### 3. File Upload Issues

**Problem**: Files not uploading or failing

**Solutions:**
- Check file size (max 500MB)
- Verify file format is supported
- Check network connectivity
- Review browser console for errors

#### 4. Build Errors

**Problem**: `npm run build` fails

**Solutions:**
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install

# Check TypeScript errors
npm run type-check

# Fix linting issues
npm run lint:fix
```

### Debug Mode

Enable detailed logging:

```env
# Add to .env.local
NEXT_PUBLIC_DEBUG=true
NODE_ENV=development
```

This will enable:
- Detailed API request/response logging
- WebSocket connection debugging
- Component state debugging

## Code Quality

### ESLint Configuration

The project uses strict ESLint rules:

```bash
# Check for issues
npm run lint

# Auto-fix issues
npm run lint:fix
```

### TypeScript Strict Mode

All code is written in TypeScript with strict mode enabled:

```bash
# Type checking
npm run type-check
```

### Prettier Integration

Code formatting is handled automatically:

```bash
# Format code
npx prettier --write .
```

## Browser Support

- **Modern Browsers**: Chrome 88+, Firefox 85+, Safari 14+, Edge 88+
- **Features Required**: ES2020, WebSocket, File API, Drag & Drop API
- **Progressive Enhancement**: Graceful degradation for older browsers

## Contributing

1. **Code Style**: Follow existing patterns and use provided tooling
2. **Component Development**: Create Storybook stories for new components
3. **Testing**: Write unit tests for new functionality
4. **Documentation**: Update README for new features

## License

This project is proprietary to Devoteam.

## Support

For issues or questions:
- Check the troubleshooting section above
- Review Storybook documentation for component usage
- Contact the development team