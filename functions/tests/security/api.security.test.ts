import { InjectionPreventionService, SecurityError } from '../../src/shared/security/injection.prevention';

describe('API Security Validators', () => {
  let service: InjectionPreventionService;

  beforeEach(() => {
    service = new InjectionPreventionService();
  });

  describe('NoSQL Injection Prevention', () => {
    it('should reject unauthorized collections', () => {
      expect(() => {
        service.buildSafeQuery('admin_keys', [{ field: 'id', operator: '==', value: '1' }]);
      }).toThrow(SecurityError);
    });

    it('should reject unsafe operators', () => {
      expect(() => {
        service.buildSafeQuery('users', [{ field: 'id', operator: '$where', value: '1==1' }]);
      }).toThrow(SecurityError);
    });
  });

  describe('SSRF Protection', () => {
    it('should block local interfaces', () => {
      expect(service.validateUrl('https://localhost/admin')).toBe(false);
      expect(service.validateUrl('http://127.0.0.1:8080')).toBe(false);
      expect(service.validateUrl('https://169.254.169.254/latest/meta-data')).toBe(false); // AWS IMDS
    });

    it('should enforce HTTPS', () => {
      expect(service.validateUrl('http://external-server.com')).toBe(false);
      expect(service.validateUrl('https://external-server.com')).toBe(true);
    });
  });

  describe('Prototype Pollution', () => {
    it('should strip prototype headers from payloads', () => {
      const payload = JSON.parse('{"__proto__": {"admin": true}}');
      expect(() => service.sanitizePayload(payload)).toThrow(SecurityError);
    });
  });
});
