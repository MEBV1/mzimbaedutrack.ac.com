/**
 * MzimbaEduTrack Realtime Synchronization Engine
 * Handles real-time database changes
 */

const Realtime = {
    _client: null,
    _subscriptions: {},
    _listeners: {},

    initialize(supabaseClient) {
        if (!supabaseClient) {
            console.warn('Realtime: No Supabase client provided');
            return;
        }

        this._client = supabaseClient;
        this._setupSubscriptions();
        console.log('✓ Realtime engine initialized');
    },

    _setupSubscriptions() {
        const tables = ['learners', 'results', 'result_subjects', 'schools'];

        tables.forEach(table => {
            this._subscribeToTable(table);
        });
    },

    _subscribeToTable(table) {
        if (this._subscriptions[table]) {
            return;
        }

        const subscription = this._client
            .channel(`public:${table}`)
            .on(
                'postgres_changes',
                {
                    event: '*',
                    schema: 'public',
                    table: table
                },
                (payload) => {
                    console.log(`Realtime: ${table} changed`, payload);
                    this._notifyListeners(`${table}_changed`, payload);
                }
            )
            .subscribe((status) => {
                console.log(`Realtime: ${table} subscription status:`, status);
            });

        this._subscriptions[table] = subscription;
    },

    addEventListener(eventName, callback) {
        if (!this._listeners[eventName]) {
            this._listeners[eventName] = [];
        }
        this._listeners[eventName].push(callback);
    },

    _notifyListeners(eventName, payload) {
        if (this._listeners[eventName]) {
            this._listeners[eventName].forEach(callback => {
                try {
                    callback(payload);
                } catch (err) {
                    console.error(`Realtime listener error for ${eventName}:`, err);
                }
            });
        }
    },

    cleanup() {
        Object.values(this._subscriptions).forEach(sub => {
            if (sub && typeof sub.unsubscribe === 'function') {
                sub.unsubscribe();
            }
        });
        this._subscriptions = {};
        this._listeners = {};
        console.log('✓ Realtime engine cleaned up');
    }
};

window.Realtime = Realtime;
