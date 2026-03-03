import { Request, Response, NextFunction } from 'express';
import { ZodSchema } from 'zod';
/**
 * Validate request body against a Zod schema
 */
export declare function validateBody(schema: ZodSchema): (req: Request, _res: Response, next: NextFunction) => void;
/**
 * Request logging middleware
 */
export declare function requestLogger(req: Request, res: Response, next: NextFunction): void;
/**
 * CORS configuration
 */
export declare function corsConfig(): {
    origin: string[];
    methods: string[];
    allowedHeaders: string[];
    credentials: boolean;
    maxAge: number;
};
//# sourceMappingURL=validation.middleware.d.ts.map