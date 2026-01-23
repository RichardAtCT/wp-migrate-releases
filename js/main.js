/**
 * WP-Migrate Website JavaScript
 * Theme toggle, copy functionality, FAQ accordion, animations
 */

(function() {
    'use strict';

    // ========================================
    // Theme Management
    // ========================================

    /**
     * Toggle between clean and CLI themes
     */
    function toggleTheme() {
        const html = document.documentElement;
        const currentTheme = html.getAttribute('data-theme');
        const newTheme = currentTheme === 'cli' ? 'clean' : 'cli';

        html.setAttribute('data-theme', newTheme);
        localStorage.setItem('wp-migrate-theme', newTheme);

        // Update all labels
        updateThemeLabels(newTheme);

        // Trigger effects on theme change
        if (newTheme === 'cli') {
            triggerGlitchEffect();
            playBootSequence();
        }

        // Update matrix visibility
        updateMatrixVisibility();
    }

    /**
     * Update all theme toggle labels
     */
    function updateThemeLabels(theme) {
        const labels = document.querySelectorAll('.theme-label');
        labels.forEach(label => {
            label.textContent = theme === 'cli' ? 'CLI' : 'Clean';
        });
    }

    /**
     * Initialize theme from localStorage
     */
    function initTheme() {
        const savedTheme = localStorage.getItem('wp-migrate-theme') || 'clean';
        document.documentElement.setAttribute('data-theme', savedTheme);
        updateThemeLabels(savedTheme);
    }

    /**
     * Play boot sequence animation for CLI theme
     */
    function playBootSequence() {
        const asciiArt = document.querySelector('.ascii-art');
        if (asciiArt) {
            asciiArt.style.opacity = '0';
            setTimeout(() => {
                asciiArt.style.transition = 'opacity 0.5s ease';
                asciiArt.style.opacity = '1';
            }, 100);
        }

        // Animate terminal lines if visible
        const terminalLines = document.querySelectorAll('.terminal-body .terminal-line');
        terminalLines.forEach((line, index) => {
            line.style.opacity = '0';
            setTimeout(() => {
                line.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                line.style.opacity = '1';
            }, index * 200);
        });
    }

    /**
     * Glitch effect when switching to CLI mode
     */
    function triggerGlitchEffect() {
        const body = document.body;
        body.style.animation = 'glitch 0.3s ease';
        setTimeout(() => {
            body.style.animation = '';
        }, 300);
    }

    // ========================================
    // Matrix Rain Effect
    // ========================================

    let matrixAnimationId = null;

    /**
     * Initialize matrix rain canvas effect for CLI mode
     */
    function initMatrixRain() {
        if (document.documentElement.getAttribute('data-theme') !== 'cli') return;

        const canvas = document.getElementById('matrix-canvas');
        if (!canvas) return;

        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;

        const chars = '01';
        const fontSize = 14;
        const columns = canvas.width / fontSize;
        const drops = Array(Math.floor(columns)).fill(1);

        function draw() {
            if (document.documentElement.getAttribute('data-theme') !== 'cli') {
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                matrixAnimationId = null;
                return;
            }

            ctx.fillStyle = 'rgba(13, 13, 13, 0.05)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            ctx.fillStyle = '#00ff9f15';
            ctx.font = fontSize + 'px monospace';

            for (let i = 0; i < drops.length; i++) {
                const text = chars[Math.floor(Math.random() * chars.length)];
                ctx.fillText(text, i * fontSize, drops[i] * fontSize);

                if (drops[i] * fontSize > canvas.height && Math.random() > 0.975) {
                    drops[i] = 0;
                }
                drops[i]++;
            }
            matrixAnimationId = requestAnimationFrame(draw);
        }

        // Cancel any existing animation
        if (matrixAnimationId) {
            cancelAnimationFrame(matrixAnimationId);
        }

        draw();
    }

    /**
     * Update matrix canvas visibility based on theme
     */
    function updateMatrixVisibility() {
        const canvas = document.getElementById('matrix-canvas');
        if (canvas) {
            const isCli = document.documentElement.getAttribute('data-theme') === 'cli';
            canvas.style.opacity = isCli ? '1' : '0';
            if (isCli && !matrixAnimationId) {
                initMatrixRain();
            }
        }
    }

    // ========================================
    // Copy Functionality
    // ========================================

    /**
     * Copy install command to clipboard
     */
    function copyInstall() {
        const command = 'curl -fsSL https://wp-migrate.dev/install.sh | bash';
        navigator.clipboard.writeText(command).then(() => {
            // Show toast notification
            const toast = document.getElementById('toast');
            if (toast) {
                toast.classList.add('show');
                setTimeout(() => toast.classList.remove('show'), 2500);
            }

            // Update copy buttons
            const copyBtns = document.querySelectorAll('.copy-btn');
            copyBtns.forEach(btn => {
                btn.classList.add('copied');
                btn.innerHTML = '<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M5 13l4 4L19 7"/></svg>';
            });

            setTimeout(() => {
                copyBtns.forEach(btn => {
                    btn.classList.remove('copied');
                    btn.innerHTML = '<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>';
                });
            }, 2000);
        });
    }

    // ========================================
    // FAQ Accordion
    // ========================================

    /**
     * Initialize FAQ accordion functionality
     */
    function initFAQ() {
        document.querySelectorAll('.faq-question').forEach(button => {
            button.addEventListener('click', () => {
                const item = button.parentElement;
                const isOpen = item.classList.contains('open');

                // Close all other items
                document.querySelectorAll('.faq-item').forEach(i => i.classList.remove('open'));

                // Toggle current item
                if (!isOpen) {
                    item.classList.add('open');
                }
            });
        });
    }

    // ========================================
    // Scroll Animations
    // ========================================

    /**
     * Initialize intersection observer for fade-in animations
     */
    function initScrollAnimations() {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach((entry, index) => {
                if (entry.isIntersecting) {
                    setTimeout(() => {
                        entry.target.classList.add('visible');
                    }, index * 100);
                }
            });
        }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });

        document.querySelectorAll('.fade-in').forEach(el => observer.observe(el));
    }

    // ========================================
    // Navigation
    // ========================================

    /**
     * Initialize navbar background on scroll
     */
    function initNavScroll() {
        const nav = document.querySelector('nav');
        if (!nav) return;

        window.addEventListener('scroll', () => {
            if (window.scrollY > 50) {
                nav.classList.add('scrolled');
            } else {
                nav.classList.remove('scrolled');
            }
        });
    }

    /**
     * Initialize smooth scrolling for anchor links
     */
    function initSmoothScroll() {
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function(e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            });
        });
    }

    // ========================================
    // Window Resize Handler
    // ========================================

    /**
     * Handle window resize for matrix canvas
     */
    function initResizeHandler() {
        let resizeTimeout;
        window.addEventListener('resize', () => {
            clearTimeout(resizeTimeout);
            resizeTimeout = setTimeout(() => {
                const canvas = document.getElementById('matrix-canvas');
                if (canvas && document.documentElement.getAttribute('data-theme') === 'cli') {
                    canvas.width = window.innerWidth;
                    canvas.height = window.innerHeight;
                }
            }, 250);
        });
    }

    // ========================================
    // Initialization
    // ========================================

    /**
     * Initialize all functionality when DOM is ready
     */
    function init() {
        // Theme
        initTheme();
        setTimeout(updateMatrixVisibility, 100);

        // UI Components
        initFAQ();
        initScrollAnimations();
        initNavScroll();
        initSmoothScroll();
        initResizeHandler();

    }

    // Expose functions globally for onclick handlers
    window.toggleTheme = toggleTheme;
    window.copyInstall = copyInstall;

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
