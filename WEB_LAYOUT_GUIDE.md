# SnakeBite AI - Web Layout Guide

## Landing Page Layouts

### Mobile Layout (< 900px width)
```
┌─────────────────────────┐
│   [Logo]                │
│   SnakeBite AI          │
│   Subtitle              │
├─────────────────────────┤
│ ⚠ EMERGENCY NOTICE      │
├─────────────────────────┤
│                         │
│   [CAPTURE SNAKE]       │
│   (Large Button)        │
│                         │
├─────────────────────────┤
│   [AI ASSISTANT]        │
├─────────────────────────┤
│  [History] [Treatment]  │
├─────────────────────────┤
│   How It Works          │
│   1. Capture photo      │
│   2. AI identifies      │
│   3. Get treatment      │
│   4. Chat with AI       │
└─────────────────────────┘
```

### Web Layout (> 900px width)
```
┌────────────────────────────────────────────────┐
│               [Logo - 100px]                   │
│              SnakeBite AI (48px)               │
│      Emergency Snake Identification...         │
├────────────────────────────────────────────────┤
│          ⚠ EMERGENCY NOTICE                    │
├────────────────────────────────────────────────┤
│                                                │
│  ┌──────────────────┬──────────────────┐      │
│  │                  │                  │      │
│  │                  │  [AI ASSISTANT]  │      │
│  │  [CAPTURE SNAKE] │                  │      │
│  │   (Main Action)  ├──────────────────┤      │
│  │                  │ [History][Treat] │      │
│  │                  │                  │      │
│  └──────────────────┴──────────────────┘      │
│                                                │
├────────────────────────────────────────────────┤
│              How It Works                      │
│  ① Capture  ② Identify  ③ Treatment  ④ Chat  │
└────────────────────────────────────────────────┘
         Max Width: 1200px (centered)
```

## Chat Assistant Layouts

### Mobile Layout
```
┌─────────────────────────┐
│ ← SnakeBite AI         │
│   Emergency Support     │
├─────────────────────────┤
│                         │
│  AI: Hello, how can...  │
│                         │
│       User: I need...   │
│                         │
│  AI: Here's what...     │
│                         │
│       User: Thanks      │
│                         │
│  (scrollable)           │
│                         │
├─────────────────────────┤
│ [Type message...] [>]   │
└─────────────────────────┘
```

### Web Layout
```
┌────────────────────────────────────────────────┐
│ ← SnakeBite AI Assistant                      │
│   Emergency Medical Support                    │
├────────────────────────────────────────────────┤
│                                                │
│     AI: Hello, how can I help...               │
│                                                │
│              User: I need help with...         │
│                                                │
│     AI: Here's what you should do...           │
│                                                │
│              User: Thank you                   │
│                                                │
│     (scrollable messages, centered)            │
│                                                │
├────────────────────────────────────────────────┤
│     [Type your message here...]      [Send]    │
└────────────────────────────────────────────────┘
              Max Width: 1000px (centered)
```

## Responsive Sizing Reference

### Icon Sizes
| Component      | Mobile    | Web      |
|---------------|-----------|----------|
| App Logo      | 20% width | 100px    |
| Logo Icon     | 10% width | 50px     |
| Camera Icon   | 15% width | 80px     |
| AI Icon       | 8% width  | 40px     |
| Quick Access  | 10% width | 48px     |

### Font Sizes
| Text Element     | Mobile       | Web    |
|-----------------|--------------|--------|
| App Title       | headlineLarge| 48px   |
| Subtitle        | bodyMedium   | 18px   |
| Button Title    | headlineSmall| 28px   |
| Body Text       | bodySmall    | 14-16px|

### Padding/Spacing
| Area              | Mobile    | Web    |
|-------------------|-----------|--------|
| Page Horizontal   | 6% width  | 48px   |
| Page Vertical     | 3% height | 40px   |
| Button Padding    | 4% width  | 24-32px|
| Section Spacing   | 2-5% height| 24-40px|

## Color Scheme (Unchanged)
- Primary: Medical Blue/Teal
- Secondary: Purple/Magenta  
- Error/Emergency: Red
- Background: Light/White
- Text: Dark Gray (varying emphasis)

## Breakpoints
- **Mobile**: 0 - 900px
- **Wide Screen**: > 900px

## Quick Start Commands

### Run on Web (Chrome)
```powershell
.\run_web.ps1
```

### Run on Mobile Device
```powershell
.\run.ps1
# or
flutter run -d R58N66898VT
```

### Build for Web Production
```powershell
flutter build web --release
```

## Testing Checklist
- [ ] Test on Chrome (desktop)
- [ ] Test on Firefox (desktop)
- [ ] Test on Edge (desktop)
- [ ] Test at 1920x1080 resolution
- [ ] Test at 1366x768 resolution
- [ ] Test at 1024x768 resolution
- [ ] Test mobile view (375px)
- [ ] Test tablet view (768px)
- [ ] Verify all buttons clickable
- [ ] Check text readability
- [ ] Verify centered alignment
- [ ] Test navigation flow

## Key Features
✅ Responsive design (mobile + web)
✅ Centered layout on wide screens
✅ Maximum width constraints
✅ Scaled components
✅ Grid-based layout for web
✅ Touch and mouse support
✅ Keyboard navigation
✅ Fast hot reload
✅ Production-ready
