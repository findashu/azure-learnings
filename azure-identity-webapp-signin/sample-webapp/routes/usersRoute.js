import { Router } from 'express';
import {GRAPH_ME_ENDPOINT} from '../auth/authConfig.js';
const router = Router();

// custom middleware to check auth state
function isAuthenticated(req, res, next) {
    if (!req.session.isAuthenticated) {
        return res.redirect('/auth/signin'); // redirect to sign-in route
    }
    next();
};

router.get('/id',
    isAuthenticated, // check if user is authenticated
    async function (req, res, next) {
        res.render('id', { idTokenClaims: req.session.account.idTokenClaims });
    }
);

router.get('/profile',
    isAuthenticated, // check if user is authenticated
    async function (req, res, next) {
        try {
            const graphResponse = await fetch(
                GRAPH_ME_ENDPOINT,
                {
                headers: {
                    Authorization: `Bearer ${req.session.accessToken}`
                }
            });
            const data = await graphResponse.json();
            console.log('Graph Me response', data)



            res.render('profile', { profile: data });
        } catch (error) {
            console.log(`Fetch error at graph me endpoint`)
            next(error);
        }
    }
);

export default router;
