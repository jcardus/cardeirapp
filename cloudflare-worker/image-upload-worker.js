/**
 * Cloudflare Worker for handling image uploads to Cloudflare Images API
 * This worker acts as a CORS-enabled proxy for Flutter Web apps
 */

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

export default {
  async fetch(request, env) {
    // Handle CORS preflight requests
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: corsHeaders,
      });
    }

    // Only allow POST requests
    if (request.method !== 'POST') {
      return new Response('Method not allowed', {
        status: 405,
        headers: corsHeaders,
      });
    }

    try {
      // Get environment variables
      const CLOUDFLARE_ACCOUNT_ID = env.CLOUDFLARE_ACCOUNT_ID || '53b1e246a278dc3b175ca615904cf34e'
      const CLOUDFLARE_API_TOKEN = env.CLOUDFLARE_API_TOKEN;

      if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_API_TOKEN) {
        return new Response(
          JSON.stringify({
            success: false,
            error: 'Missing Cloudflare configuration',
          }),
          {
            status: 500,
            headers: {
              'Content-Type': 'application/json',
              ...corsHeaders,
            },
          }
        );
      }

      // Get the form data from the request
      const formData = await request.formData();

      // Create a new FormData to forward to Cloudflare Images API
      const uploadFormData = new FormData();

      // Copy the file from the incoming request
      const file = formData.get('file');
      if (!file) {
        return new Response(
          JSON.stringify({
            success: false,
            error: 'No file provided',
          }),
          {
            status: 400,
            headers: {
              'Content-Type': 'application/json',
              ...corsHeaders,
            },
          }
        );
      }

      uploadFormData.append('file', file);

      // Forward the request to Cloudflare Images API
      const cloudflareApiUrl = `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/images/v1`;

      const apiResponse = await fetch(cloudflareApiUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${CLOUDFLARE_API_TOKEN}`,
        },
        body: uploadFormData,
      });

      // Get the response from Cloudflare API
      const responseData = await apiResponse.json();

      // Return the response with CORS headers
      return new Response(JSON.stringify(responseData), {
        status: apiResponse.status,
        headers: {
          'Content-Type': 'application/json',
          ...corsHeaders,
        },
      });
    } catch (error) {
      return new Response(
        JSON.stringify({
          success: false,
          error: error.message,
        }),
        {
          status: 500,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      );
    }
  },
};
